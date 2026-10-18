import Foundation

/// Build-time configuration, read from Info.plist (values come from the xcconfig files).
public struct AppEnvironment: Sendable {
    public let name: String
    public let apiBaseURL: URL

    public init(name: String, apiBaseURL: URL) {
        self.name = name
        self.apiBaseURL = apiBaseURL
    }

    /// Placeholder backend used until a real API exists.
    public static let placeholder = AppEnvironment(
        name: "placeholder",
        apiBaseURL: URL(string: "https://jsonplaceholder.typicode.com")!
    )

    public static func fromBundle(_ bundle: Bundle = .main) -> AppEnvironment {
        guard
            let raw = bundle.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            let url = URL(string: raw), url.scheme != nil
        else { return .placeholder }
        let name = bundle.object(forInfoDictionaryKey: "APP_ENVIRONMENT") as? String ?? "unknown"
        return AppEnvironment(name: name, apiBaseURL: url)
    }
}
