import Foundation

/// Receipt for a successfully completed Pix transfer, shown on the
/// confirmation screen.
public struct PixTransferReceipt: Equatable {
    public let recipient: PixRecipient
    public let amount: Decimal
    public let sourceAccountLabel: String
    public let bankName: String
    public let transactionId: String
    public let dateLabel: String

    public init(
        recipient: PixRecipient,
        amount: Decimal,
        sourceAccountLabel: String,
        bankName: String,
        transactionId: String,
        dateLabel: String
    ) {
        self.recipient = recipient
        self.amount = amount
        self.sourceAccountLabel = sourceAccountLabel
        self.bankName = bankName
        self.transactionId = transactionId
        self.dateLabel = dateLabel
    }
}
