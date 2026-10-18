# KindTree Swap

SwiftUI iOS 17+ app using **MVVM + a Service/Client layer** and Swift Concurrency (`async/await`, `AsyncThrowingStream`, actors). No Combine, no third-party dependencies.

## Architecture

```
View (SwiftUI) -> ViewModel (@MainActor @Observable) -> Service (protocol) -> Client (protocol) -> URLSession
                          \---------- Core: Sendable models, AppError, LoadState ----------/
```

| Layer | Where | Responsibility |
| --- | --- | --- |
| View | `Features/<Feature>/*View.swift` | Render state, forward intent. No logic. |
| ViewModel | `Features/<Feature>/*ViewModel.swift` | Owns `LoadState<T>`; exposes `async` intent methods. Depends on Service protocols only. |
| Service | `Services/` | Business logic, DTO to domain mapping, caches (actors), streams. A `Live` and a `Mock` per service. |
| Client | `Networking/` | Transport only (`HTTPClient`, `Endpoint`). Maps every failure to `AppError`. |
| Core | `Core/` | Domain models, `AppError`, `LoadState`, `AppEnvironment`, logging. |

Targets in `Packages/KindTreeKit` depend downward only (`Features -> Services -> Networking -> Core`), so a Feature can not import Networking.
The app target (`KindTreeSwap/`) is the composition root: `AppContainer` builds the Live services, `AppRouter` owns navigation.

## Conventions
- Views trigger work with `.task { await vm.load() }` and `.refreshable`; SwiftUI cancels the task. A cancelled load restores the previous state instead of showing an error.
- Live data is an `AsyncThrowingStream`; the ViewModel consumes it in a stored `Task` and cancels it in `stopListening()`.
- Models are `Sendable` value types; DTOs stay inside the Services target.
- Swift 6 language mode, strict concurrency complete.

## Adding a feature
1. Add/extend a service protocol in `Services/` with a Live and a Mock implementation.
2. Add `Features/<Name>/` with a `@MainActor @Observable` ViewModel and a View (include `#Preview` with the Mock).
3. Add a factory to `AppContainer` and a `Route` case + destination in `AppRouter`/`RootView` if it is navigable.
4. Test the ViewModel with the Mock service in `Tests/FeaturesTests`.

## Configuration
`Config/*.xcconfig` set `API_BASE_URL` and `APP_ENVIRONMENT` per build configuration; they reach the app through `Config/Info.plist` and `AppEnvironment.fromBundle()`. The base URL is currently the public placeholder `jsonplaceholder.typicode.com`.

## Tests
```
cd Packages/KindTreeKit && swift test
```
