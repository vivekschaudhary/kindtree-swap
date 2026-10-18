import Core

/// Domain-level API for items. ViewModels depend on this, not on any client.
public protocol ItemServicing: Sendable {
    func fetchItems() async throws -> [Item]
    func fetchItem(id: Item.ID) async throws -> Item

    /// Live feed of the full item list. Finishes when the consumer's task is cancelled.
    func itemUpdates() -> AsyncThrowingStream<[Item], Error>
}
