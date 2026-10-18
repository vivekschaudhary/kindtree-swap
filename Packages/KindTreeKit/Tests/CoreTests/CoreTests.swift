import Foundation
import Testing
@testable import Core

struct AppErrorTests {
    @Test func mapsCancellation() {
        #expect(AppError.from(CancellationError()) == .cancelled)
        #expect(AppError.from(URLError(.cancelled)) == .cancelled)
    }

    @Test func mapsURLError() {
        let error = AppError.from(URLError(.notConnectedToInternet))
        guard case .network = error else { Issue.record("expected .network, got \(error)"); return }
    }

    @Test func passesThroughAppError() {
        #expect(AppError.from(AppError.unauthorized) == .unauthorized)
    }
}

struct LoadStateTests {
    @Test func accessors() {
        let loaded = LoadState.loaded(3)
        #expect(loaded.value == 3)
        #expect(LoadState<Int>.loading.isLoading)
        #expect(LoadState<Int>.failed(.notFound).error == .notFound)
    }
}
