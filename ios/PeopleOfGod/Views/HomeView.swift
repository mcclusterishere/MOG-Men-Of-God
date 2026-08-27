import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: SharedStore

    var body: some View {
        ZStack {
            POGBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    showingUpCard
                    messagesCallout
                    activityList
                    principleCard
                }
                .padding(18)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(spacing: 13) {
            PeopleOfGodMark(size: 47)
            VStack(alignment: .leading, spacing: 2) {
                Text("PEOPLE OF GOD")
                    .font(.caption2.weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(POGTheme.warmGold)
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(POGTheme.cream)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private var showingUpCard: some View {
        HStack(spacing: 22) {
            ZStack {
                Circle()
                    .stroke(POGTheme.cream.opacity(0.08), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: store.milestoneProgress)
                    .stroke(
                        AngularGradient(colors: [POGTheme.gold, POGTheme.warmGold], center: .center),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(store.showingUpTotal)")
                        .font(.title.bold())
                        .foregroundStyle(POGTheme.cream)
                    Text("ACTS")
                        .font(.caption2.bold())
                        .tracking(1)
                        .foregroundStyle(POGTheme.softCream)
                }
            }
            .frame(width: 112, height: 112)

            VStack(alignment: .leading, spacing: 7) {
                Text("Showing Up")
                    .font(.title2.bold())
                    .foregroundStyle(POGTheme.cream)
                Text("\(store.nextMilestone - store.showingUpTotal) acts until your next collective milestone.")
                    .font(.subheadline)
                    .foregroundStyle(POGTheme.softCream)
                Text("Care is counted. Pain is not scored.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POGTheme.warmGold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pogCard()
    }

    private var messagesCallout: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("PLAY IT IN iMESSAGE", systemImage: "message.fill")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(POGTheme.warmGold)
            Text("Start with the people already in your circle.")
                .font(.title3.bold())
                .foregroundStyle(POGTheme.cream)
            Text("Open a conversation, tap +, choose More, then People of God. Send a check-in and let the circle respond from the card.")
                .font(.subheadline)
                .foregroundStyle(POGTheme.softCream)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pogCard()
    }

    private var activityList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CARE ACTIVITIES")
                .font(.caption.weight(.bold))
                .tracking(1.6)
                .foregroundStyle(POGTheme.softCream)

            NavigationLink {
                PrivateCheckInView()
            } label: {
                ActivityRow(activity: .circleCheck)
            }

            NavigationLink {
                PrayerPracticeView()
            } label: {
                ActivityRow(activity: .prayerChain)
            }

            NavigationLink {
                SpeakLifePracticeView()
            } label: {
                ActivityRow(activity: .speakLife)
            }
        }
        .buttonStyle(.plain)
    }

    private var principleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("THE RULE")
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(POGTheme.warmGold)
            Text("Gamify the care, never the pain.")
                .font(.title3.bold())
                .foregroundStyle(POGTheme.cream)
            Text("Nobody loses a streak for struggling, being quiet, or missing a day. The only progress is showing up for yourself and other people.")
                .font(.subheadline)
                .foregroundStyle(POGTheme.softCream)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pogCard()
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return switch hour {
        case 5..<12: "Good morning."
        case 12..<17: "Good afternoon."
        case 17..<22: "Good evening."
        default: "How are you, really?"
        }
    }
}

private struct ActivityRow: View {
    let activity: CircleActivity

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: activity.symbol)
                .font(.title3)
                .foregroundStyle(POGTheme.midnight)
                .frame(width: 45, height: 45)
                .background(POGTheme.warmGold, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.title)
                    .font(.headline)
                    .foregroundStyle(POGTheme.cream)
                Text(activity.shortDescription)
                    .font(.caption)
                    .foregroundStyle(POGTheme.softCream)
            }

            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .foregroundStyle(POGTheme.softCream.opacity(0.55))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(POGTheme.deepBlue.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(POGTheme.cream.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
