import Core
import Networking

/// Transport shape for the placeholder API; mapped to `Item` at the service boundary.
struct ItemDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let body: String

    var domain: Item { Item(id: id, title: title, summary: body) }
}

/// Shared mutable state lives in an actor.
actor ItemCache {
    private var items: [Item.ID: Item] = [:]

    func store(_ newItems: [Item]) {
        for item in newItems { items[item.id] = item }
    }

    func item(id: Item.ID) -> Item? { items[id] }
}

public final class LiveItemService: ItemServicing {
    private let client: any HTTPClient
    private let cache = ItemCache()
    private let pollInterval: Duration

    public init(client: any HTTPClient, pollInterval: Duration = .seconds(30)) {
        self.client = client
        self.pollInterval = pollInterval
    }

    public func fetchItems() async throws -> [Item] {
        let dtos: [ItemDTO] = try await client.send(Endpoint(path: "posts"))
        let items = dtos.map(\.domain)
        await cache.store(items)
        return items
    }

    public func fetchItem(id: Item.ID) async throws -> Item {
        if let cached = await cache.item(id: id) { return cached }
        let dto: ItemDTO = try await client.send(Endpoint(path: "posts/\(id)"))
        let item = dto.domain
        await cache.store([item])
        return item
    }

    public func itemUpdates() -> AsyncThrowingStream<[Item], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    while !Task.isCancelled {
                        continuation.yield(try await self.fetchItems())
                        try await Task.sleep(for: self.pollInterval)
                    }
                    continuation.finish()
                } catch {
                    let appError = AppError.from(error)
                    if appError == .cancelled {
                        continuation.finish()
                    } else {
                        continuation.finish(throwing: appError)
                    }
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
