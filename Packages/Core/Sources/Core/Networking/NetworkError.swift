import Foundation

/// Transport/network errors, generic enough for any feature module to use.
/// Data layers must map `NetworkError` to their own domain errors —
/// Presentation should never see this type directly (see the Pix feature's
/// plan.md).
public enum NetworkError: Error, Equatable {
    case invalidURL
    case noConnection
    case timeout
    case unauthorized
    case notFound
    case server(statusCode: Int)
    case decoding
    case unknown

    public var isRetryable: Bool {
        switch self {
        case .noConnection, .timeout, .server:
            return true
        case .invalidURL, .unauthorized, .notFound, .decoding, .unknown:
            return false
        }
    }
}
