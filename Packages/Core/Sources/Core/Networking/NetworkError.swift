import Foundation

/// Erros de transporte/rede, genéricos o suficiente para qualquer módulo de
/// feature usar. Camadas de Data devem mapear `NetworkError` para erros de
/// domínio próprios — a Presentation nunca deve enxergar este tipo
/// diretamente (ver plan.md da feature Pix).
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
