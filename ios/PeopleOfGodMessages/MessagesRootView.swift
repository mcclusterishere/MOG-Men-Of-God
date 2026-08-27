import SwiftUI

typealias MessageSendHandler = (MessagePayload) async throws -> Void

struct MessagesRootView: View {
    enum Route {
        case menu
        case circleCheck
        case prayerChain
        case speakLife
    }

    let incoming: MessagePayload?
    let onRequestExpanded: () -> Void
    let onSend: MessageSendHandler

    @State private var route: Route

    init(
        incoming: MessagePayload?,
        onRequestExpanded: @escaping () -> Void,
        onSend: @escaping MessageSendHandler
    ) {
        self.incoming = incoming
        self.onRequestExpanded = onRequestExpanded
        self.onSend = onSend
        _route = State(initialValue: Self.route(for: incoming))
    }

    var body: some View {
        ZStack {
            POGBackground()

            switch route {
            case .menu:
                MessagesMenu { activity in
                    onRequestExpanded()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        route = Self.route(for: activity)
                    }
                }
            case .circleCheck:
                CircleCheckMessageView(incoming: incoming, onSend: onSend) {
                    route = .menu
                }
            case .prayerChain:
                PrayerChainMessageView(incoming: incoming, onSend: onSend) {
                    route = .menu
                }
            case .speakLife:
                SpeakLifeMessageView(incoming: incoming, onSend: onSend) {
                    route = .menu
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private static func route(for incoming: MessagePayload?) -> Route {
        guard let activity = incoming?.activity else { return .menu }
        return route(for: activity)
    }

    private static func route(for activity: CircleActivity) -> Route {
        switch activity {
        case .circleCheck: .circleCheck
        case .prayerChain: .prayerChain
        case .speakLife: .speakLife
        }
    }
}

private struct MessagesMenu: View {
    let select: (CircleActivity) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 11) {
                    PeopleOfGodMark(size: 40)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("PEOPLE OF GOD")
                            .font(.caption2.weight(.bold))
                            .tracking(1.7)
                            .foregroundStyle(POGTheme.warmGold)
                        Text("Check in. Pray. Show up.")
                            .font(.headline)
                            .foregroundStyle(POGTheme.cream)
                    }
                }

                ForEach(CircleActivity.allCases) { activity in
                    Button {
                        select(activity)
                    } label: {
                        HStack(spacing: 13) {
                            Image(systemName: activity.symbol)
                                .font(.headline)
                                .foregroundStyle(POGTheme.midnight)
                                .frame(width: 38, height: 38)
                                .background(POGTheme.warmGold, in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.title)
                                    .font(.headline)
                                Text(activity.shortDescription)
                                    .font(.caption)
                                    .foregroundStyle(POGTheme.softCream)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                        }
                        .foregroundStyle(POGTheme.cream)
                        .padding(12)
                        .background(POGTheme.cream.opacity(0.055), in: RoundedRectangle(cornerRadius: 17))
                    }
                    .buttonStyle(.plain)
                }

                Text("Care earns the milestone. Feelings never earn or lose points.")
                    .font(.caption2)
                    .foregroundStyle(POGTheme.softCream)
            }
            .padding(14)
        }
    }
}

struct MessageFlowHeader: View {
    let activity: CircleActivity
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(POGTheme.cream)
                    .frame(width: 34, height: 34)
                    .background(POGTheme.cream.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)

            Image(systemName: activity.symbol)
                .foregroundStyle(POGTheme.warmGold)
            Text(activity.title)
                .font(.headline)
                .foregroundStyle(POGTheme.cream)
            Spacer()
            PeopleOfGodMark(size: 32)
        }
    }
}

struct SendStateNotice: View {
    let isSending: Bool
    let sent: Bool
    let error: String?

    var body: some View {
        Group {
            if isSending {
                Label("Preparing card…", systemImage: "hourglass")
            } else if sent {
                Label("Card inserted. Tap the blue Send arrow.", systemImage: "checkmark.circle.fill")
            } else if let error {
                Label(error, systemImage: "exclamationmark.triangle.fill")
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(error == nil ? POGTheme.softCream : Color.red.opacity(0.9))
    }
}
