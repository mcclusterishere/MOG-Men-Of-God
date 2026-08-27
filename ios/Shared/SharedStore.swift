import Foundation
import SwiftUI

@MainActor
final class SharedStore: ObservableObject {
    static let appGroupID = "group.org.mccluster.peopleofgod"
    static let defaults = UserDefaults(suiteName: appGroupID) ?? .standard
    static let shared = SharedStore(defaults: defaults)

    private enum Key {
        static let checkIns = "care.checkIns"
        static let supportActs = "care.supportActs"
        static let prayerActs = "care.prayerActs"
        static let lastActivityAt = "care.lastActivityAt"
        static let didCompleteWelcome = "app.didCompleteWelcome"
    }

    private let defaults: UserDefaults

    @Published private(set) var checkIns: Int
    @Published private(set) var supportActs: Int
    @Published private(set) var prayerActs: Int
    @Published private(set) var lastActivityAt: Date?
    @Published var didCompleteWelcome: Bool {
        didSet { defaults.set(didCompleteWelcome, forKey: Key.didCompleteWelcome) }
    }

    init(defaults: UserDefaults) {
        self.defaults = defaults
        checkIns = defaults.integer(forKey: Key.checkIns)
        supportActs = defaults.integer(forKey: Key.supportActs)
        prayerActs = defaults.integer(forKey: Key.prayerActs)
        lastActivityAt = defaults.object(forKey: Key.lastActivityAt) as? Date
        didCompleteWelcome = defaults.bool(forKey: Key.didCompleteWelcome)
    }

    var showingUpTotal: Int { checkIns + supportActs + prayerActs }

    var nextMilestone: Int {
        let milestones = [5, 10, 25, 50, 100, 250]
        return milestones.first(where: { $0 > showingUpTotal }) ?? (((showingUpTotal / 100) + 1) * 100)
    }

    var milestoneProgress: Double {
        guard nextMilestone > 0 else { return 0 }
        return min(Double(showingUpTotal) / Double(nextMilestone), 1)
    }

    func recordPrivateCheckIn(_ checkIn: PrivateCheckIn) {
        // Deliberately store only participation. Feeling, requested support, and
        // sharing choice are never persisted as analytics or profile data.
        checkIns += 1
        lastActivityAt = checkIn.createdAt
        persist()
    }

    func recordSupportAct() {
        supportActs += 1
        lastActivityAt = Date()
        persist()
    }

    func recordPrayerAct() {
        prayerActs += 1
        lastActivityAt = Date()
        persist()
    }

    private func persist() {
        defaults.set(checkIns, forKey: Key.checkIns)
        defaults.set(supportActs, forKey: Key.supportActs)
        defaults.set(prayerActs, forKey: Key.prayerActs)
        defaults.set(lastActivityAt, forKey: Key.lastActivityAt)
    }
}
