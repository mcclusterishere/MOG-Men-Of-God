import XCTest
@testable import PeopleOfGod

@MainActor
final class SharedStoreTests: XCTestCase {
    func testPrivateCheckInPersistsParticipationOnly() throws {
        let suite = "PeopleOfGodTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = SharedStore(defaults: defaults)
        store.recordPrivateCheckIn(
            PrivateCheckIn(
                state: .needSupportNow,
                support: [.professionalSupport, .call],
                shareChoice: .privateOnly,
                createdAt: Date()
            )
        )

        XCTAssertEqual(store.checkIns, 1)
        let persistedText = defaults.dictionaryRepresentation().description
        XCTAssertFalse(persistedText.contains(CheckInState.needSupportNow.rawValue))
        XCTAssertFalse(persistedText.contains(SupportKind.professionalSupport.rawValue))
        XCTAssertFalse(persistedText.contains(ShareChoice.privateOnly.rawValue))
    }
}
