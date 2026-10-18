import Foundation

/// The single error type that crosses layer boundaries.
public enum AppError: Error, Equatable, Sendable {
    case network(String)
    case decoding(String)
    case unauthorized
    case server(status: Int)
    case notFound
    case cancelled
    case unknown(String)

    /// Normalizes any thrown error into an `AppError`.
    public static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError { return appError }
        if error is CancellationError { return .cancelled }
        if let urlError = error as? URLError {
            return urlError.code == .cancelled ? .cancelled : .network(urlError.localizedDescription)
        }
        if error is DecodingError { return .decoding(String(describing: error)) }
        return .unknown(error.localizedDescription)
    }
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network(let message): "Network error: \(message)"
        case .decoding: "We couldn't read the server response."
        case .unauthorized: "You need to sign in again."
        case .server(let status): "The server returned an error (\(status))."
        case .notFound: "That item could not be found."
        case .cancelled: "The request was cancelled."
        case .unknown(let message): message
        }
    }
}
