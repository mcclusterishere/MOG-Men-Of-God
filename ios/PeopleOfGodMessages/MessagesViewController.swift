import Messages
import SwiftUI
import UIKit

final class MessagesViewController: MSMessagesAppViewController {
    private var hostingController: UIHostingController<AnyView>?
    private weak var currentConversation: MSConversation?

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        currentConversation = conversation
        installRoot(for: conversation)
    }

    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
        currentConversation = nil
    }

    private func installRoot(for conversation: MSConversation) {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()

        let incoming = MessagePayload(url: conversation.selectedMessage?.url)
        let root = MessagesRootView(
            incoming: incoming,
            onRequestExpanded: { [weak self] in
                self?.requestPresentationStyle(.expanded)
            },
            onSend: { [weak self] payload in
                guard let self else {
                    throw MessagesExtensionError.noActiveConversation
                }
                try await self.insert(payload: payload)
            }
        )
        .environmentObject(SharedStore.shared)

        let hosting = UIHostingController(rootView: AnyView(root))
        hosting.view.backgroundColor = UIColor.clear
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
        hostingController = hosting
    }

    @MainActor
    private func insert(payload: MessagePayload) async throws {
        guard let conversation = currentConversation else {
            throw MessagesExtensionError.noActiveConversation
        }

        let session: MSSession
        if MessagePayload(url: conversation.selectedMessage?.url)?.roundID == payload.roundID,
           let selectedSession = conversation.selectedMessage?.session {
            session = selectedSession
        } else {
            session = MSSession()
        }

        let message = MessageFactory.makeMessage(payload: payload, session: session)
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            conversation.insert(message) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        requestPresentationStyle(.compact)
    }
}

private enum MessagesExtensionError: LocalizedError {
    case noActiveConversation

    var errorDescription: String? {
        "Open a conversation and try again."
    }
}
