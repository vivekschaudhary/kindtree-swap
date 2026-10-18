import Core
import Foundation

public struct URLSessionHTTPClient: HTTPClient {
    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func send<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        let request = endpoint.urlRequest(baseURL: baseURL)
        AppLogger.network.debug("\(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "")")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AppError.from(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw AppError.network("Invalid response")
        }
        switch http.statusCode {
        case 200..<300: break
        case 401: throw AppError.unauthorized
        case 404: throw AppError.notFound
        default: throw AppError.server(status: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            AppLogger.network.error("Decoding \(T.self) failed: \(String(describing: error))")
            throw AppError.from(error)
        }
    }
}
