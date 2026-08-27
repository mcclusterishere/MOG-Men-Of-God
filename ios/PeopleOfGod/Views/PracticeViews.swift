import SwiftUI

struct PrayerPracticeView: View {
    @EnvironmentObject private var store: SharedStore
    @State private var request = ""
    @State private var didRecord = false

    var body: some View {
        ZStack {
            POGBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    activityHeader(
                        kicker: "PRAYER CHAIN",
                        title: "No request stands alone.",
                        body: "Name what you want prayer for, or leave it unspoken. Sharing is always your choice."
                    )

                    TextField("Prayer request (optional)", text: $request, axis: .vertical)
                        .lineLimit(3...7)
                        .padding(16)
                        .foregroundStyle(POGTheme.cream)
                        .background(POGTheme.cream.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))

                    Button(didRecord ? "Prayer moment recorded" : "I prayed") {
                        store.recordPrayerAct()
                        didRecord = true
                    }
                    .buttonStyle(POGPrimaryButtonStyle())
                    .disabled(didRecord)

                    if !request.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ShareLink(item: "Please pray with me: \(request)") {
                            Label("Share this request", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(POGSecondaryButtonStyle())

                        Text("The exact words above become visible in whichever app or conversation you choose.")
                            .font(.caption)
                            .foregroundStyle(POGTheme.softCream)
                    }

                    Text("For the interactive prayer count, open People of God inside Messages and start a Prayer Chain.")
                        .font(.footnote)
                        .foregroundStyle(POGTheme.softCream)
                        .pogCard()
                }
                .padding(18)
            }
        }
        .navigationTitle("Prayer Chain")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(POGTheme.midnight, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct SpeakLifePracticeView: View {
    @EnvironmentObject private var store: SharedStore
    @State private var affirmation = ""
    @State private var didCount = false

    var body: some View {
        ZStack {
            POGBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    activityHeader(
                        kicker: "SPEAK LIFE",
                        title: "Say something specific.",
                        body: "Skip generic praise. Name the strength, sacrifice, growth, or character you actually see in somebody."
                    )

                    TextField("What do you want them to know?", text: $affirmation, axis: .vertical)
                        .lineLimit(4...8)
                        .padding(16)
                        .foregroundStyle(POGTheme.cream)
                        .background(POGTheme.cream.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))

                    if !affirmation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ShareLink(item: affirmation) {
                            Label("Send these words", systemImage: "paperplane.fill")
                        }
                        .buttonStyle(POGPrimaryButtonStyle())
                        .simultaneousGesture(TapGesture().onEnded {
                            if !didCount {
                                store.recordSupportAct()
                                didCount = true
                            }
                        })
                    }

                    Text("For a People of God result card, compose Speak Life from inside Messages.")
                        .font(.footnote)
                        .foregroundStyle(POGTheme.softCream)
                        .pogCard()
                }
                .padding(18)
            }
        }
        .navigationTitle("Speak Life")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(POGTheme.midnight, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

@ViewBuilder
private func activityHeader(kicker: String, title: String, body: String) -> some View {
    VStack(alignment: .leading, spacing: 7) {
        Text(kicker)
            .font(.caption.weight(.bold))
            .tracking(1.6)
            .foregroundStyle(POGTheme.warmGold)
        Text(title)
            .font(.largeTitle.bold())
            .foregroundStyle(POGTheme.cream)
        Text(body)
            .foregroundStyle(POGTheme.softCream)
    }
}
