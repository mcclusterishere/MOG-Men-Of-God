import XCTest
@testable import PeopleOfGod

final class MessagePayloadTests: XCTestCase {
    func testPayloadRoundTripPreservesPublicFields() throws {
        let roundID = UUID()
        let source = MessagePayload(
            roundID: roundID,
            activity: .circleCheck,
            stage: .response,
            prompt: "How are you, really?",
            publicResponse: "I checked in. I could use prayer and a call.",
            support: [.prayer, .call],
            showingUpCount: 4
        )

        let decoded = try XCTUnwrap(MessagePayload(url: source.encodedURL()))

        XCTAssertEqual(decoded.roundID, roundID)
        XCTAssertEqual(decoded.activity, .circleCheck)
        XCTAssertEqual(decoded.stage, .response)
        XCTAssertEqual(decoded.publicResponse, source.publicResponse)
        XCTAssertEqual(decoded.support, [.prayer, .call])
        XCTAssertEqual(decoded.showingUpCount, 4)
    }

    func testPayloadNeverContainsPrivateFeelingState() throws {
        let payload = MessagePayload(
            activity: .circleCheck,
            stage: .response,
            prompt: "How are you, really?",
            publicResponse: "I checked in.",
            showingUpCount: 1
        )

        let urlText = try XCTUnwrap(payload.encodedURL()).absoluteString

        XCTAssertFalse(urlText.contains(CheckInState.needSupportNow.rawValue))
        XCTAssertFalse(urlText.contains(CheckInState.carryingSomething.rawValue))
        XCTAssertFalse(urlText.contains("feeling"))
        XCTAssertFalse(urlText.contains("mood"))
    }

    func testRejectsUnknownFuturePayloadVersion() {
        let url = URL(string: "peopleofgod://circle?v=99&round=95AB0232-68A8-44DA-8E1F-A729449C10CF&activity=circleCheck&stage=invitation&prompt=Check%20in&count=0")
        XCTAssertNil(MessagePayload(url: url))
    }

    func testRejectsUnrelatedURL() {
        XCTAssertNil(MessagePayload(url: URL(string: "https://example.com/check-in")))
    }
}
