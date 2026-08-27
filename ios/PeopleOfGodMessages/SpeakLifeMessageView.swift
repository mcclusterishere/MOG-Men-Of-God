import SwiftUI

struct SpeakLifeMessageView: View {
    @EnvironmentObject private var store: SharedStore

    let incoming: MessagePayload?
    let onSend: MessageSendHandler
    let onBack: () -> Void

    @State private var words = ""
    @State private var isSending = false
    @State private var sent = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MessageFlowHeader(activity: .speakLife, onBack: onBack)

                if let incoming, let response = incoming.publicResponse {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SOMEONE SPOKE LIFE")
                            .font(.caption.weight(.bold))
                            .tracking(1.3)
                            .foregroundStyle(POGTheme.warmGold)
                        Text("“\(response)”")
                            .font(.title3.bold())
                            .foregroundStyle(POGTheme.cream)
                        Text("Receive it—then speak life into somebody else.")
                            .font(.caption)
                            .foregroundStyle(POGTheme.softCream)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .pogCard()
                }

                Text("MAKE IT SPECIFIC")
                    .font(.caption.weight(.bold))
                    .tracking(1.3)
                    .foregroundStyle(POGTheme.warmGold)
                Text("Name the strength, sacrifice, growth, or character you actually see.")
                    .font(.subheadline)
                    .foregroundStyle(POGTheme.softCream)

                TextField("What do you want them to know?", text: $words, axis: .vertical)
                    .lineLimit(4...7)
                    .padding(14)
                    .foregroundStyle(POGTheme.cream)
                    .background(POGTheme.cream.opacity(0.06), in: RoundedRectangle(cornerRadius: 17))

                Text("These exact words will be visible to everyone in this conversation.")
                    .font(.caption)
                    .foregroundStyle(POGTheme.softCream)

                Button("Insert Speak Life card") {
                    sendWords()
                }
                .buttonStyle(POGPrimaryButtonStyle())
                .disabled(words.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending || sent)
                .opacity(words.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)

                SendStateNotice(isSending: isSending, sent: sent, error: errorMessage)
            }
            .padding(14)
            .padding(.bottom, 20)
        }
    }

    private func sendWords() {
        let trimmed = String(words.trimmingCharacters(in: .whitespacesAndNewlines).prefix(400))
        guard !trimmed.isEmpty else { return }
        store.recordSupportAct()
        let payload = MessagePayload(
            roundID: incoming?.roundID ?? UUID(),
            activity: .speakLife,
            stage: .response,
            prompt: "Speak life into somebody today.",
            publicResponse: trimmed,
            showingUpCount: (incoming?.showingUpCount ?? 0) + 1
        )

        isSending = true
        errorMessage = nil
        Task { @MainActor in
            do {
                try await onSend(payload)
                isSending = false
                sent = true
            } catch {
                isSending = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
