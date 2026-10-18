import Core
import Services
import SwiftUI

public struct SampleDetailView: View {
    @State private var viewModel: SampleDetailViewModel

    public init(viewModel: SampleDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle("Detail")
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .failed(let error):
            ContentUnavailableView(
                "Couldn't load item",
                systemImage: "exclamationmark.triangle",
                description: Text(error.localizedDescription)
            )
        case .loaded(let item):
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title).font(.title2.bold())
                    Text(item.summary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SampleDetailView(viewModel: SampleDetailViewModel(id: 1, service: MockItemService()))
    }
}
