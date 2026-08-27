import SwiftUI

struct CircleCheckMessageView: View {
    @EnvironmentObject private var store: SharedStore

    let incoming: MessagePayload?
    let onSend: MessageSendHandler
    let onBack: () -> Void

    @State private var selectedState: CheckInState?
    @State private var selectedSupport: Set<SupportKind> = []
    @State private var shareChoice: ShareChoice = .checkedInOnly
    @State private var isSending = false
    @State private var sent = false
    @State private var savedPrivately = false
    @State private var errorMessage: String?
    @State private var supportedIncoming = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MessageFlowHeader(activity: .circleCheck, onBack: onBack)

                if let incoming {
                    incomingCard(incoming)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("HOW ARE YOU, REALLY?")
                        .font(.caption.weight(.bold))
                        .tracking(1.3)
                        .foregroundStyle(POGTheme.warmGold)
                    Text("Your feeling stays on this iPhone.")
                        .font(.subheadline)
                        .foregroundStyle(POGTheme.softCream)
                }

                ForEach(CheckInState.allCases) { state in
                    POGChoiceRow(
                        title: state.title,
                        symbol: state.symbol,
                        isSelected: selectedState == state
                    ) {
                        selectedState = state
                    }
                }

                if selectedState?.requiresSafetyOffer == true {
                    SafetySupportView(compact: true)
                }

                if selectedState != nil {
                    Text("WHAT WOULD HELP?")
                        .font(.caption.weight(.bold))
                        .tracking(1.3)
                        .foregroundStyle(POGTheme.warmGold)

                    ForEach(SupportKind.allCases) { support in
                        POGChoiceRow(
                            title: support.title,
                            symbol: support.symbol,
                            isSelected: selectedSupport.contains(support)
                        ) {
                            if selectedSupport.contains(support) {
                                selectedSupport.remove(support)
                            } else {
                                selectedSupport.insert(support)
                            }
                        }
                    }

                    Text("WHAT GOES INTO THE CHAT?")
                        .font(.caption.weight(.bold))
                        .tracking(1.3)
                        .foregroundStyle(POGTheme.warmGold)

                    ForEach(ShareChoice.allCases) { choice in
                        POGChoiceRow(
                            title: choice.title,
                            detail: choice.detail,
                            symbol: choice.symbol,
                            isSelected: shareChoice == choice
                        ) {
                            shareChoice = choice
                        }
                    }

                    Button(shareChoice == .privateOnly ? "Save privately" : "Insert check-in card") {
                        completeCheckIn()
                    }
                    .buttonStyle(POGPrimaryButtonStyle())
                    .disabled(isSending || sent || savedPrivately)

                    if savedPrivately {
                        Label("Saved locally. Nothing was inserted into the chat.", systemImage: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(POGTheme.softCream)
                    }

                    SendStateNotice(isSending: isSending, sent: sent, error: errorMessage)
                }
            }
            .padding(14)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func incomingCard(_ payload: MessagePayload) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(payload.cardTitle)
                .font(.headline)
                .foregroundStyle(POGTheme.cream)
            if let response = payload.publicResponse {
                Text(response)
                    .font(.subheadline)
                    .foregroundStyle(POGTheme.softCream)
            }
            if !payload.support.isEmpty {
                Text("Requested: \(payload.support.map(\.shortTitle).joined(separator: ", "))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POGTheme.warmGold)

                Button(supportedIncoming ? "Support counted" : "I will show up") {
                    supportIncoming(payload)
                }
                .buttonStyle(POGSecondaryButtonStyle())
                .disabled(supportedIncoming || isSending)
            }
            Text("\(payload.showingUpCount) showing up")
                .font(.caption)
                .foregroundStyle(POGTheme.softCream)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pogCard()
    }

    private func completeCheckIn() {
        guard let selectedState else { return }
        let checkIn = PrivateCheckIn(
            state: selectedState,
            support: selectedSupport,
            shareChoice: shareChoice,
            createdAt: Date()
        )
        store.recordPrivateCheckIn(checkIn)

        guard shareChoice != .privateOnly else {
            withAnimation { savedPrivately = true }
            return
        }

        let sharedSupport = shareChoice == .supportRequest ? Array(selectedSupport).sorted { $0.rawValue < $1.rawValue } : []
        let response: String
        if shareChoice == .supportRequest, !sharedSupport.isEmpty {
            response = "I checked in. I could use \(sharedSupport.map(\.shortTitle).joined(separator: ", "))."
        } else {
            response = "I checked in. Please keep showing up."
        }

        let payload = MessagePayload(
            roundID: incoming?.roundID ?? UUID(),
            activity: .circleCheck,
            stage: .response,
            prompt: incoming?.prompt ?? "How are you, really?",
            publicResponse: response,
            support: sharedSupport,
            showingUpCount: (incoming?.showingUpCount ?? 0) + 1
        )
        send(payload)
    }

    private func supportIncoming(_ payload: MessagePayload) {
        store.recordSupportAct()
        supportedIncoming = true
        let updated = MessagePayload(
            roundID: payload.roundID,
            activity: .circleCheck,
            stage: .supported,
            prompt: payload.prompt,
            publicResponse: "Someone in the circle committed to follow up.",
            support: payload.support,
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
            case .success:
                sent = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
