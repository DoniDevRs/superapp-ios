import Foundation

/// Um destinatário de Pix, salvo (recente) ou resolvido a partir de uma
/// chave digitada manualmente.
public struct PixRecipient: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let initials: String
    public let bankName: String
    public let keyMasked: String
    /// Rótulo de "última transação" exibido na lista de recentes (ex.: "ontem").
    /// `nil` para destinatários resolvidos por chave digitada na hora.
    public let lastTransactionLabel: String?

    public init(
        id: String,
        name: String,
        initials: String,
        bankName: String,
        keyMasked: String,
        lastTransactionLabel: String? = nil
    ) {
        self.id = id
        self.name = name
        self.initials = initials
        self.bankName = bankName
        self.keyMasked = keyMasked
        self.lastTransactionLabel = lastTransactionLabel
    }
}
