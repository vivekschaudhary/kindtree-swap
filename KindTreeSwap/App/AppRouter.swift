import Core
import Observation

enum Route: Hashable {
    case itemDetail(Item.ID)
}

@MainActor
@Observable
final class AppRouter {
    var path: [Route] = []

    func push(_ route: Route) { path.append(route) }
    func popToRoot() { path.removeAll() }
}
