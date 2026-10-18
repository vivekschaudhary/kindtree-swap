import Core

/// Deterministic service for previews and tests.
public struct MockItemService: ItemServicing {
    public var items: [Item]
    public var delay: Duration
    public var error: AppError?

    public init(items: [Item] = MockItemService.sampleItems, delay: Duration = .zero, error: AppError? = nil) {
        self.items = items
        self.delay = delay
        self.error = error
    }

    public static let sampleItems: [Item] = (1...5).map {
        Item(id: $0, title: "Sample item \($0)", summary: "Summary for sample item \($0).")
    }

    public func fetchItems() async throws -> [Item] {
        try await simulateLatency()
        return items
    }

    public func fetchItem(id: Item.ID) async throws -> Item {
        try await simulateLatency()
        guard let item = items.first(where: { $0.id == id }) else { throw AppError.notFound }
        return item
    }

    public func itemUpdates() -> AsyncThrowingStream<[Item], Error> {
        let snapshot = items
        let failure = error
        return AsyncThrowingStream { continuation in
            if let failure {
                continuation.finish(throwing: failure)
            } else {
                continuation.yield(snapshot)
                continuation.finish()
            }
        }
    }

    private func simulateLatency() async throws {
        if delay > .zero { try await Task.sleep(for: delay) }
        if let error { throw error }
    }
}
