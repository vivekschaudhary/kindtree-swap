import Core
import Features
import Networking
import Services

/// Composition root: the only place that knows about concrete Live types.
@MainActor
final class AppContainer {
    let environment: AppEnvironment
    let itemService: any ItemServicing

    init(environment: AppEnvironment) {
        self.environment = environment
        let client = URLSessionHTTPClient(baseURL: environment.apiBaseURL)
        self.itemService = LiveItemService(client: client)
    }

    /// For previews: no network.
    init(environment: AppEnvironment = .placeholder, itemService: any ItemServicing) {
        self.environment = environment
        self.itemService = itemService
    }

    func makeSampleViewModel() -> SampleViewModel {
        SampleViewModel(service: itemService)
    }

    func makeSampleDetailViewModel(id: Item.ID) -> SampleDetailViewModel {
        SampleDetailViewModel(id: id, service: itemService)
    }
}
