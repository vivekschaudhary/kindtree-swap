import Foundation

/// Describes a single HTTP request, independent of base URL and transport.
public struct Endpoint: Sendable {
    public enum Method: String, Sendable {
        case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
    }

    public var path: String
    public var method: Method
    public var query: [URLQueryItem]
    public var headers: [String: String]
    public var body: Data?

    public init(
        path: String,
        method: Method = .get,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
    }

    /// Convenience for JSON request bodies.
    public static func json<Body: Encodable>(
        path: String,
        method: Method = .post,
        body: Body,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> Endpoint {
        Endpoint(
            path: path,
            method: method,
            headers: ["Content-Type": "application/json"],
            body: try encoder.encode(body)
        )
    }

    func urlRequest(baseURL: URL) -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !query.isEmpty { components?.queryItems = query }
        var request = URLRequest(url: components?.url ?? baseURL)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        for (field, value) in headers { request.setValue(value, forHTTPHeaderField: field) }
        return request
    }
}
