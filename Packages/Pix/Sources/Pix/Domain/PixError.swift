import Foundation

/// Erros de domínio da feature Pix. A camada de Data é responsável por
/// mapear erros de transporte (`Core.NetworkError`) para este tipo — a
/// Presentation nunca deve enxergar erros de rede diretamente (ver
/// plan.md: "Tratamento de erros de rede mapeado para tipos de erro de
/// domínio").
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
