import Messages
import SwiftUI
import UIKit

final class MessagesViewController: MSMessagesAppViewController {
    private var hostingController: UIHostingController<MessagesRootView>?
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
            onSend: { [weak self] payload, completion in
                self?.insert(payload: payload, completion: completion)
            }
        )
        .environmentObject(SharedStore.shared)

        let hosting = UIHostingController(rootView: root)
        hosting.view.backgroundColor = .clear
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

    private func insert(
        payload: MessagePayload,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let conversation = currentConversation else {
            completion(.failure(MessagesExtensionError.noActiveConversation))
            return
        }

        let session: MSSession
        if MessagePayload(url: conversation.selectedMessage?.url)?.roundID == payload.roundID,
           let selectedSession = conversation.selectedMessage?.session {
            session = selectedSession
        } else {
            session = MSSession()
        }

        let message = MessageFactory.makeMessage(payload: payload, session: session)
        conversation.insert(message) { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                    self?.requestPresentationStyle(.compact)
                }
            }
        }
    }
}

private enum MessagesExtensionError: LocalizedError {
    case noActiveConversation

    var errorDescription: String? {
        "Open a conversation and try again."
    }
}
