import Core
import Services
import Testing
@testable import Features

@MainActor
struct SampleViewModelTests {
    @Test func loadsItems() async {
        let viewModel = SampleViewModel(service: MockItemService())
        #expect(viewModel.state == .idle)
        await viewModel.load()
        #expect(viewModel.state == .loaded(MockItemService.sampleItems))
    }

    @Test func surfacesFailure() async {
        let viewModel = SampleViewModel(service: MockItemService(error: .server(status: 500)))
        await viewModel.load()
        #expect(viewModel.state == .failed(.server(status: 500)))
    }

    @Test func refreshKeepsContentWhileFetching() async {
        let viewModel = SampleViewModel(service: MockItemService())
        await viewModel.load()
        await viewModel.refresh()
        #expect(viewModel.state.value?.count == 5)
    }

    @Test func cancelledLoadRestoresIdle() async {
        let viewModel = SampleViewModel(service: MockItemService(delay: .seconds(5)))
        let task = Task { await viewModel.load() }
        await Task.yield()
        task.cancel()
        await task.value
        #expect(viewModel.state == .idle)
    }

    @Test func streamUpdatesState() async throws {
        let viewModel = SampleViewModel(service: MockItemService())
        viewModel.startListening()
        for _ in 0..<50 where viewModel.state.value == nil { try await Task.sleep(for: .milliseconds(10)) }
        #expect(viewModel.state.value?.count == 5)
        viewModel.stopListening()
    }
}
