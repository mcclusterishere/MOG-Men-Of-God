import SwiftUI

struct PrayerChainMessageView: View {
    @EnvironmentObject private var store: SharedStore

    let incoming: MessagePayload?
    let onSend: MessageSendHandler
    let onBack: () -> Void

    @State private var request = ""
    @State private var shareWords = false
    @State private var isSending = false
    @State private var sent = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MessageFlowHeader(activity: .prayerChain, onBack: onBack)

                if let incoming {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("PRAYER REQUEST")
                            .font(.caption.weight(.bold))
                            .tracking(1.3)
                            .foregroundStyle(POGTheme.warmGold)
                        Text(incoming.publicResponse ?? "Unspoken prayer request.")
                            .font(.title3.bold())
                            .foregroundStyle(POGTheme.cream)
                        Text("\(incoming.showingUpCount) people have shown up in prayer.")
                            .font(.subheadline)
                            .foregroundStyle(POGTheme.softCream)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .pogCard()

                    Button("I prayed") {
                        respondToPrayer(incoming)
                    }
                    .buttonStyle(POGPrimaryButtonStyle())
                    .disabled(isSending || sent)

                    SendStateNotice(isSending: isSending, sent: sent, error: errorMessage)

                    Divider().overlay(POGTheme.cream.opacity(0.15))
                    Text("START ANOTHER REQUEST")
                        .font(.caption.weight(.bold))
                        .tracking(1.3)
                        .foregroundStyle(POGTheme.warmGold)
                } else {
                    Text("NO REQUEST STANDS ALONE")
                        .font(.caption.weight(.bold))
                        .tracking(1.3)
                        .foregroundStyle(POGTheme.warmGold)
                    Text("Ask for prayer without having to explain everything.")
                        .font(.title3.bold())
                        .foregroundStyle(POGTheme.cream)
                }

                if incoming == nil {
                    TextField("Prayer request (optional)", text: $request, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(14)
                        .foregroundStyle(POGTheme.cream)
                        .background(POGTheme.cream.opacity(0.06), in: RoundedRectangle(cornerRadius: 17))

                    Toggle("Share these exact words in the chat", isOn: $shareWords)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POGTheme.cream)
                        .tint(POGTheme.warmGold)

                    Text(shareWords ? "Everyone in this conversation will see the request text." : "The card will say only “Unspoken prayer request.”")
                        .font(.caption)
                        .foregroundStyle(POGTheme.softCream)

                    Button("Insert prayer card") {
                        startPrayer()
                    }
                    .buttonStyle(POGPrimaryButtonStyle())
                    .disabled(isSending || sent)

                    SendStateNotice(isSending: isSending, sent: sent, error: errorMessage)
                }
            }
            .padding(14)
            .padding(.bottom, 20)
        }
    }

    private func startPrayer() {
        let trimmed = request.trimmingCharacters(in: .whitespacesAndNewlines)
        let publicText = shareWords && !trimmed.isEmpty ? String(trimmed.prefix(400)) : "Unspoken prayer request."
        let payload = MessagePayload(
            activity: .prayerChain,
            stage: .invitation,
            prompt: "Will you pray with me?",
            publicResponse: publicText,
            showingUpCount: 0
        )
        send(payload)
    }

    private func respondToPrayer(_ payload: MessagePayload) {
        store.recordPrayerAct()
        let updated = MessagePayload(
            roundID: payload.roundID,
            activity: .prayerChain,
            stage: .supported,
            prompt: payload.prompt,
            publicResponse: payload.publicResponse ?? "Unspoken prayer request.",
            showingUpCount: payload.showingUpCount + 1
        )
        send(updated)
    }

    private func send(_ payload: MessagePayload) {
        isSending = true
        errorMessage = nil
        onSend(payload) { result in
            isSending = false
            switch result {
            case .success: sent = true
            case .failure(let error): errorMessage = error.localizedDescription
            }
        }
    }
}
