import Foundation

enum MessageStage: String, Codable {
    case invitation
    case response
    case supported
}

struct MessagePayload: Equatable {
    static let scheme = "peopleofgod"
    static let host = "circle"
    static let currentVersion = 1

    var version: Int = currentVersion
    var roundID: UUID = UUID()
    var activity: CircleActivity
    var stage: MessageStage
    var prompt: String
    var publicResponse: String?
    var support: [SupportKind] = []
    var showingUpCount: Int = 0

    init(
        version: Int = currentVersion,
        roundID: UUID = UUID(),
        activity: CircleActivity,
        stage: MessageStage,
        prompt: String,
        publicResponse: String? = nil,
        support: [SupportKind] = [],
        showingUpCount: Int = 0
    ) {
        self.version = version
        self.roundID = roundID
        self.activity = activity
        self.stage = stage
        self.prompt = prompt
        self.publicResponse = publicResponse
        self.support = support
        self.showingUpCount = showingUpCount
    }

    init?(url: URL?) {
        guard
            let url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == Self.scheme,
            components.host == Self.host
        else { return nil }

        let values = (components.queryItems ?? []).reduce(into: [String: String]()) { result, item in
            if let value = item.value {
                result[item.name] = value
            }
        }

        guard
            let versionText = values["v"],
            let version = Int(versionText),
            version >= 1,
            version <= Self.currentVersion,
            let roundText = values["round"],
            let roundID = UUID(uuidString: roundText),
            let activityText = values["activity"],
            let activity = CircleActivity(rawValue: activityText),
            let stageText = values["stage"],
            let stage = MessageStage(rawValue: stageText),
            let prompt = values["prompt"],
            prompt.count <= 400
        else { return nil }

        let support = (values["support"] ?? "")
            .split(separator: ",")
            .compactMap { SupportKind(rawValue: String($0)) }

        self.version = version
        self.roundID = roundID
        self.activity = activity
        self.stage = stage
        self.prompt = prompt
        self.publicResponse = values["response"].flatMap { $0.isEmpty ? nil : String($0.prefix(400)) }
        self.support = support
        self.showingUpCount = max(0, min(Int(values["count"] ?? "0") ?? 0, 10_000))
    }

    func encodedURL() -> URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        components.queryItems = [
            URLQueryItem(name: "v", value: String(version)),
            URLQueryItem(name: "round", value: roundID.uuidString),
            URLQueryItem(name: "activity", value: activity.rawValue),
            URLQueryItem(name: "stage", value: stage.rawValue),
            URLQueryItem(name: "prompt", value: String(prompt.prefix(400))),
            URLQueryItem(name: "response", value: publicResponse.map { String($0.prefix(400)) }),
            URLQueryItem(name: "support", value: support.map(\.rawValue).joined(separator: ",")),
            URLQueryItem(name: "count", value: String(max(0, showingUpCount)))
        ]
        return components.url
    }

    var cardTitle: String {
        switch (activity, stage) {
        case (.circleCheck, .invitation): "How are you, really?"
        case (.circleCheck, .response): "Someone checked in"
        case (.circleCheck, .supported): "The circle showed up"
        case (.prayerChain, .invitation): "Prayer requested"
        case (.prayerChain, .response), (.prayerChain, .supported): "Prayer chain active"
        case (.speakLife, _): "Speak Life"
        }
    }

    var cardSubtitle: String {
        if let publicResponse, !publicResponse.isEmpty { return publicResponse }
        return prompt
    }

    var summaryText: String {
        "People of God · \(activity.title) · \(showingUpCount) showing up"
    }
}
