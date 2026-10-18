import Features
import Services
import SwiftUI

struct RootView: View {
    let container: AppContainer
    @State private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            SampleListView(viewModel: container.makeSampleViewModel()) { item in
                router.push(.itemDetail(item.id))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .itemDetail(let id):
                    SampleDetailView(viewModel: container.makeSampleDetailViewModel(id: id))
                }
            }
        }
    }
}

#Preview {
    RootView(container: AppContainer(itemService: MockItemService()))
}
