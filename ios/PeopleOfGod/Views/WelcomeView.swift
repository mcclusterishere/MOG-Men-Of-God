import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var store: SharedStore
    @State private var isAdult = false
    @State private var understandsBoundary = false

    var body: some View {
        ZStack {
            POGBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 14) {
                        PeopleOfGodMark(size: 70)
                        Text("PEOPLE OF GOD")
                            .font(.caption.weight(.bold))
                            .tracking(2.4)
                            .foregroundStyle(POGTheme.warmGold)
                        Text("Check in.\nPray. Show up.")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(POGTheme.cream)
                        Text("Turn the group chats you already trust into circles where care becomes action.")
                            .font(.title3)
                            .foregroundStyle(POGTheme.softCream)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        WelcomePrinciple(
                            symbol: "lock.shield.fill",
                            title: "Private by default",
                            detail: "Your feeling and support choices stay on this iPhone unless you deliberately share a request."
                        )
                        WelcomePrinciple(
                            symbol: "person.3.fill",
                            title: "Care, not competition",
                            detail: "The circle earns collective Showing Up milestones. Nobody is ranked by how they feel."
                        )
                        WelcomePrinciple(
                            symbol: "cross.case.fill",
                            title: "Faith beside real help",
                            detail: "Prayer can support care. It never replaces qualified professional or emergency help."
                        )
                    }
                    .pogCard()

                    VStack(alignment: .leading, spacing: 14) {
                        Toggle("I am 18 or older.", isOn: $isAdult)
                        Toggle("I understand this is peer support, not therapy, diagnosis, or an emergency service.", isOn: $understandsBoundary)
                    }
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(POGTheme.cream)
                    .tint(POGTheme.warmGold)

                    Button("Enter People of God") {
                        store.didCompleteWelcome = true
                    }
                    .buttonStyle(POGPrimaryButtonStyle())
                    .disabled(!isAdult || !understandsBoundary)
                    .opacity(isAdult && understandsBoundary ? 1 : 0.45)

                    Text("If you may not be safe, call or text 988 now. Call 911 for immediate danger.")
                        .font(.caption)
                        .foregroundStyle(POGTheme.softCream)
                        .padding(.bottom, 24)
                }
                .padding(24)
            }
        }
    }
}

private struct WelcomePrinciple: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(POGTheme.warmGold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(POGTheme.cream)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(POGTheme.softCream)
            }
        }
    }
}
