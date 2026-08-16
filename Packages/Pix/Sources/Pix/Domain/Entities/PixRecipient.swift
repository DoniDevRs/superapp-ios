import Foundation

/// A Pix recipient, either saved (recent) or resolved from a manually
/// typed key.
public struct PixRecipient: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let initials: String
    public let bankName: String
    public let keyMasked: String
    /// "Last transaction" label shown in the recents list (e.g., "ontem").
    /// `nil` for recipients resolved by a key typed on the spot.
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
