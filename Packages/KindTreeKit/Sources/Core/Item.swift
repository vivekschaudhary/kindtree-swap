/// Example domain model. Replace with real KindTree domain types.
public struct Item: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let summary: String

    public init(id: Int, title: String, summary: String) {
        self.id = id
        self.title = title
        self.summary = summary
    }
}
