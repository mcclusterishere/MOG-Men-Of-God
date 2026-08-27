import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var store: SharedStore

    var body: some View {
        ZStack {
            POGBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 14) {
                        PeopleOfGodMark(size: 58)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("PEOPLE OF GOD")
                                .font(.caption.weight(.bold))
                                .tracking(1.8)
                                .foregroundStyle(POGTheme.warmGold)
                            Text("Faith-Based Check-Ins")
                                .font(.title3.bold())
                                .foregroundStyle(POGTheme.cream)
                        }
                    }

                    aboutSection(
                        title: "What this is",
                        body: "A tool for adults in trusted groups to check in, request prayer, ask for practical support, and follow through for one another."
                    )

                    aboutSection(
                        title: "What this is not",
                        body: "People of God does not provide therapy, diagnosis, medical treatment, professional counseling, or emergency response."
                    )

                    aboutSection(
                        title: "Privacy in this build",
                        body: "There are no accounts, ads, analytics, trackers, or backend. Detailed check-in selections are not persisted. Messages contain only the words a person deliberately chooses to send."
                    )

                    aboutSection(
                        title: "The rule",
                        body: "Gamify the care, never the pain. There are no mood scores, public streak penalties, or leaderboards for vulnerability."
                    )

                    Button("Show welcome and safety agreement again") {
                        store.didCompleteWelcome = false
                    }
                    .buttonStyle(POGSecondaryButtonStyle())

                    Text("Version 0.1 · McCluster Corp")
                        .font(.caption)
                        .foregroundStyle(POGTheme.softCream)
                }
                .padding(18)
            }
        }
        .navigationTitle("About")
        .toolbarBackground(POGTheme.midnight, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func aboutSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.headline)
                .foregroundStyle(POGTheme.cream)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(POGTheme.softCream)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pogCard()
    }
}
