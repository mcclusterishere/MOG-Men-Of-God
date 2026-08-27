import Foundation

enum CircleActivity: String, CaseIterable, Identifiable, Codable {
    case circleCheck
    case prayerChain
    case speakLife

    var id: String { rawValue }

    var title: String {
        switch self {
        case .circleCheck: "Circle Check"
        case .prayerChain: "Prayer Chain"
        case .speakLife: "Speak Life"
        }
    }

    var shortDescription: String {
        switch self {
        case .circleCheck: "Ask the circle how they are, really."
        case .prayerChain: "Make sure no prayer request stands alone."
        case .speakLife: "Send one specific, honest affirmation."
        }
    }

    var symbol: String {
        switch self {
        case .circleCheck: "person.3.fill"
        case .prayerChain: "hands.and.sparkles.fill"
        case .speakLife: "quote.bubble.fill"
        }
    }
}

enum CheckInState: String, CaseIterable, Identifiable, Codable {
    case steady
    case carryingSomething
    case needPrayer
    case needToTalk
    case needSupportNow

    var id: String { rawValue }

    var title: String {
        switch self {
        case .steady: "I'm steady"
        case .carryingSomething: "I'm carrying something"
        case .needPrayer: "I need prayer"
        case .needToTalk: "I need somebody to talk to"
        case .needSupportNow: "I need support right now"
        }
    }

    var symbol: String {
        switch self {
        case .steady: "circle.fill"
        case .carryingSomething: "backpack.fill"
        case .needPrayer: "hands.and.sparkles.fill"
        case .needToTalk: "bubble.left.and.bubble.right.fill"
        case .needSupportNow: "lifepreserver.fill"
        }
    }

    var requiresSafetyOffer: Bool { self == .needSupportNow }
}

enum SupportKind: String, CaseIterable, Identifiable, Codable {
    case prayer
    case call
    case listen
    case checkTomorrow
    case practicalHelp
    case professionalSupport

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prayer: "Pray for me"
        case .call: "Call me"
        case .listen: "Listen without trying to fix it"
        case .checkTomorrow: "Check on me tomorrow"
        case .practicalHelp: "Help me with something practical"
        case .professionalSupport: "Help me find professional support"
        }
    }

    var shortTitle: String {
        switch self {
        case .prayer: "prayer"
        case .call: "a call"
        case .listen: "somebody to listen"
        case .checkTomorrow: "a check-in tomorrow"
        case .practicalHelp: "practical help"
        case .professionalSupport: "professional support"
        }
    }

    var symbol: String {
        switch self {
        case .prayer: "hands.and.sparkles"
        case .call: "phone.fill"
        case .listen: "ear.fill"
        case .checkTomorrow: "calendar.badge.clock"
        case .practicalHelp: "wrench.and.screwdriver.fill"
        case .professionalSupport: "cross.case.fill"
        }
    }
}

enum ShareChoice: String, CaseIterable, Identifiable {
    case privateOnly
    case checkedInOnly
    case supportRequest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privateOnly: "Keep my answers private"
        case .checkedInOnly: "Share only that I checked in"
        case .supportRequest: "Share what support I want"
        }
    }

    var detail: String {
        switch self {
        case .privateOnly: "Nothing is sent to the conversation."
        case .checkedInOnly: "The group sees no feeling or support detail."
        case .supportRequest: "Only the support choices below go into the chat."
        }
    }

    var symbol: String {
        switch self {
        case .privateOnly: "lock.fill"
        case .checkedInOnly: "checkmark.shield.fill"
        case .supportRequest: "person.2.wave.2.fill"
        }
    }
}

struct PrivateCheckIn {
    let state: CheckInState
    let support: Set<SupportKind>
    let shareChoice: ShareChoice
    let createdAt: Date
}
