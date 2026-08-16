import Foundation

/// Domain errors for the Pix feature. The Data layer is responsible for
/// mapping transport errors (`Core.NetworkError`) to this type — Presentation
/// should never see network errors directly (see plan.md: "Network error
/// handling mapped to domain error types").
public enum PixError: Error, LocalizedError, Equatable {
    case invalidAmount
    case insufficientBalance
    case network
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Informe um valor maior que zero."
        case .insufficientBalance:
            return "Saldo insuficiente para essa transferência."
        case .network:
            return "Não foi possível concluir a operação. Verifique sua conexão e tente novamente."
        case .unknown:
            return "Algo deu errado. Tente novamente em instantes."
        }
    }
}
