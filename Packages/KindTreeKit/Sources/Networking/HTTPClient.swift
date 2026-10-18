import Core

/// Transport boundary. Services depend on this protocol, never on URLSession.
public protocol HTTPClient: Sendable {
    /// Sends the request and decodes the response body. Throws `AppError`.
    func send<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T
}
