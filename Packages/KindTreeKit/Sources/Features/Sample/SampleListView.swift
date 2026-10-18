import Core
import Services
import SwiftUI

public struct SampleListView: View {
    @State private var viewModel: SampleViewModel
    private let onSelect: (Item) -> Void

    public init(viewModel: SampleViewModel, onSelect: @escaping (Item) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSelect = onSelect
    }

    public var body: some View {
        content
            .navigationTitle("Items")
            .task { await viewModel.load() }
            .refreshable { await viewModel.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .failed(let error):
            ContentUnavailableView {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("Retry") { Task { await viewModel.refresh() } }
            }
        case .loaded(let items):
            List(items) { item in
                Button { onSelect(item) } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.headline)
                        Text(item.summary).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        SampleListView(viewModel: SampleViewModel(service: MockItemService()), onSelect: { _ in })
    }
}

#Preview("Failed") {
    NavigationStack {
        SampleListView(
            viewModel: SampleViewModel(service: MockItemService(error: .network("Offline"))),
            onSelect: { _ in }
        )
    }
}
