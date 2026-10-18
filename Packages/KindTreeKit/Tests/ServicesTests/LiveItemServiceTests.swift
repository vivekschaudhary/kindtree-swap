import Core
import Networking
import Testing
@testable import Services

/// Returns canned JSON-equivalent values keyed by path; counts calls.
private final class CountingClient: HTTPClient, @unchecked Sendable {
    private let lock = NSLock()
    private var _calls = 0
    var calls: Int { lock.withLock { _calls } }

    func send<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        lock.withLock { _calls += 1 }
        if endpoint.path == "posts" {
            return [ItemDTO(id: 1, title: "t", body: "b")] as! T
        }
        throw AppError.notFound
    }
}

extension ItemDTO {
    init(id: Int, title: String, body: String) {
        self = try! JSONDecoder().decode(ItemDTO.self, from: Data(#"{"id":\#(id),"title":"\#(title)","body":"\#(body)"}"#.utf8))
    }
}

import Foundation

struct LiveItemServiceTests {
    @Test func mapsDTOsToDomain() async throws {
        let service = LiveItemService(client: CountingClient())
        let items = try await service.fetchItems()
        #expect(items == [Item(id: 1, title: "t", summary: "b")])
    }

    @Test func fetchItemUsesCacheAfterList() async throws {
        let client = CountingClient()
        let service = LiveItemService(client: client)
        _ = try await service.fetchItems()
        let item = try await service.fetchItem(id: 1)
        #expect(item.title == "t")
        #expect(client.calls == 1)
    }

    @Test func streamEndsCleanlyWhenConsumerCancels() async throws {
        let client = CountingClient()
        let service = LiveItemService(client: client, pollInterval: .milliseconds(10))
        let consumer = Task {
            var batches = 0
            for try await _ in service.itemUpdates() { batches += 1 }
            return batches
        }
        try await Task.sleep(for: .milliseconds(80))
        consumer.cancel()
        let batches = try await consumer.value
        #expect(batches >= 1)

        let callsAfterCancel = client.calls
        try await Task.sleep(for: .milliseconds(60))
        #expect(client.calls == callsAfterCancel, "polling must stop after cancellation")
    }
}
