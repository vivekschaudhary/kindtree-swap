import Core
import Foundation
import Testing
@testable import Networking

final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: ((URLRequest) -> (Int, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let (status, data) = Self.handler?(request) ?? (500, Data())
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private struct Payload: Decodable, Sendable, Equatable { let name: String }

@Suite(.serialized)
struct URLSessionHTTPClientTests {
    private func makeClient() -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSessionHTTPClient(
            baseURL: URL(string: "https://example.test")!,
            session: URLSession(configuration: configuration)
        )
    }

    @Test func decodesSuccess() async throws {
        StubURLProtocol.handler = { _ in (200, Data(#"{"name":"leaf"}"#.utf8)) }
        let result: Payload = try await makeClient().send(Endpoint(path: "thing"))
        #expect(result == Payload(name: "leaf"))
    }

    @Test func buildsRequest() async throws {
        nonisolated(unsafe) var captured: URLRequest?
        StubURLProtocol.handler = { request in
            captured = request
            return (200, Data(#"{"name":"x"}"#.utf8))
        }
        let _: Payload = try await makeClient().send(
            Endpoint(path: "a/b", method: .post, query: [URLQueryItem(name: "q", value: "1")])
        )
        #expect(captured?.url?.absoluteString == "https://example.test/a/b?q=1")
        #expect(captured?.httpMethod == "POST")
    }

    @Test(arguments: [(401, AppError.unauthorized), (404, .notFound), (503, .server(status: 503))])
    func mapsStatusCodes(status: Int, expected: AppError) async {
        StubURLProtocol.handler = { _ in (status, Data()) }
        await #expect(throws: expected) {
            let _: Payload = try await makeClient().send(Endpoint(path: "x"))
        }
    }

    @Test func mapsDecodingFailure() async {
        StubURLProtocol.handler = { _ in (200, Data(#"{"wrong":1}"#.utf8)) }
        do {
            let _: Payload = try await makeClient().send(Endpoint(path: "x"))
            Issue.record("expected throw")
        } catch let error as AppError {
            guard case .decoding = error else { Issue.record("expected .decoding, got \(error)"); return }
        } catch {
            Issue.record("unexpected error \(error)")
        }
    }
}
