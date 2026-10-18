import Core
import Observation
import Services

@MainActor
@Observable
public final class SampleViewModel {
    public private(set) var state: LoadState<[Item]> = .idle

    private let service: any ItemServicing
    private var streamTask: Task<Void, Never>?

    public init(service: any ItemServicing) {
        self.service = service
    }

    /// Initial load. Safe to call from `.task`; cancellation returns the state to where it was.
    public func load() async {
        guard state.value == nil else { return }
        await fetch(showLoading: true)
    }

    /// Pull-to-refresh: keeps showing current content while fetching.
    public func refresh() async {
        await fetch(showLoading: state.value == nil)
    }

    /// Starts consuming the live feed. Replaces any previous subscription.
    public func startListening() {
        stopListening()
        streamTask = Task { [service] in
            do {
                for try await items in service.itemUpdates() {
                    state = .loaded(items)
                }
            } catch {
                let appError = AppError.from(error)
                if appError != .cancelled { state = .failed(appError) }
            }
        }
    }

    public func stopListening() {
        streamTask?.cancel()
        streamTask = nil
    }

    private func fetch(showLoading: Bool) async {
        let previous = state
        if showLoading { state = .loading }
        do {
            state = .loaded(try await service.fetchItems())
        } catch {
            let appError = AppError.from(error)
            if appError == .cancelled {
                state = previous
            } else {
                AppLogger.ui.error("Load failed: \(appError.localizedDescription)")
                state = .failed(appError)
            }
        }
    }
}
