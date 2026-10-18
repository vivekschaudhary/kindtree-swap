import Core
import Observation
import Services

@MainActor
@Observable
public final class SampleDetailViewModel {
    public private(set) var state: LoadState<Item> = .idle

    private let id: Item.ID
    private let service: any ItemServicing

    public init(id: Item.ID, service: any ItemServicing) {
        self.id = id
        self.service = service
    }

    public func load() async {
        state = .loading
        do {
            state = .loaded(try await service.fetchItem(id: id))
        } catch {
            let appError = AppError.from(error)
            state = appError == .cancelled ? .idle : .failed(appError)
        }
    }
}
