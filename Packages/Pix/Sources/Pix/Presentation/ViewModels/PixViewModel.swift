import Foundation
import Core

/// Observable state for the complete Pix transfer flow.
///
/// This ViewModel is a single instance shared by the flow's 3 screens
/// (`SelectRecipientView` -> `ReviewPaymentView` -> `ConfirmationView`) —
/// `PixCoordinator` creates one instance and injects the same reference into
/// each screen, so the state (selected recipient, amount, receipt) carries
/// across navigation without needing to be manually relayed between
/// per-screen ViewModels.
///
/// Talks only to Use Cases (never directly to `PixRepository` or to
/// networking), per the project's Clean Architecture rule.
@MainActor
public final class PixViewModel: ObservableObject {
    // MARK: Recipient selection

    @Published public var searchQuery: String = ""
    @Published public private(set) var recentRecipients: [PixRecipient] = []
    @Published public private(set) var selectedRecipient: PixRecipient?

    // MARK: Amount and review

    @Published public var typedAmountDigits: String = ""
    @Published public private(set) var accountBalance: PixAccountBalance?
    @Published public var message: String = ""

    // MARK: Confirmation

    @Published public private(set) var receipt: PixTransferReceipt?

    // MARK: Cross-cutting state

    @Published public private(set) var isLoading: Bool = false
    @Published public var errorMessage: String?

    private let fetchRecentRecipientsUseCase: FetchRecentRecipientsUseCase
    private let fetchAccountBalanceUseCase: FetchAccountBalanceUseCase
    private let validateTransferAmountUseCase: ValidateTransferAmountUseCase
    private let confirmPixTransferUseCase: ConfirmPixTransferUseCase

    public init(
        fetchRecentRecipientsUseCase: FetchRecentRecipientsUseCase,
        fetchAccountBalanceUseCase: FetchAccountBalanceUseCase,
        validateTransferAmountUseCase: ValidateTransferAmountUseCase,
        confirmPixTransferUseCase: ConfirmPixTransferUseCase
    ) {
        self.fetchRecentRecipientsUseCase = fetchRecentRecipientsUseCase
        self.fetchAccountBalanceUseCase = fetchAccountBalanceUseCase
        self.validateTransferAmountUseCase = validateTransferAmountUseCase
        self.confirmPixTransferUseCase = confirmPixTransferUseCase
    }

    // MARK: - Derived state

    public var filteredRecipients: [PixRecipient] {
        guard !searchQuery.isEmpty else { return recentRecipients }
        return recentRecipients.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
                || $0.keyMasked.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    public var amount: Decimal {
        CurrencyFormatter.decimal(fromTypedDigits: typedAmountDigits)
    }

    public var formattedAmount: String {
        CurrencyFormatter.string(from: amount)
    }

    public var formattedBalance: String {
        guard let accountBalance else { return "" }
        return CurrencyFormatter.string(from: accountBalance.amount)
    }

    public var canConfirmTransfer: Bool {
        guard !isLoading, selectedRecipient != nil, let accountBalance else { return false }
        return (try? validateTransferAmountUseCase.validate(amount: amount, balance: accountBalance.amount)) != nil
    }

    // MARK: - Intents

    public func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let recipients = fetchRecentRecipientsUseCase.execute()
            async let balance = fetchAccountBalanceUseCase.execute()
            recentRecipients = try await recipients
            accountBalance = try await balance
        } catch {
            errorMessage = message(for: error)
        }
        isLoading = false
    }

    /// Selects a recipient and resets amount/message/receipt — a previous
    /// selection's state must never leak into a new selection, regardless
    /// of how the user got back to this screen (tapping "Trocar" or the
    /// system's swipe-back gesture).
    public func selectRecipient(_ recipient: PixRecipient) {
        selectedRecipient = recipient
        typedAmountDigits = ""
        message = ""
        receipt = nil
        errorMessage = nil
    }

    public func changeRecipient() {
        selectedRecipient = nil
        typedAmountDigits = ""
        message = ""
        errorMessage = nil
    }

    public func appendAmountDigit(_ digit: String) {
        typedAmountDigits.append(digit)
        errorMessage = nil
    }

    public func removeLastAmountDigit() {
        guard !typedAmountDigits.isEmpty else { return }
        typedAmountDigits.removeLast()
    }

    /// Executes the transfer confirmation.
    ///
    /// Returns `true` when the submission was actually sent to the Use Case
    /// (success or network/server failure) — in that case the Coordinator
    /// should navigate to `ConfirmationView`, which shows success or error.
    /// Returns `false` when local validation failed before any call
    /// (e.g., amount above the balance) — in that case the current screen
    /// stays and shows the error inline, without navigating.
    @discardableResult
    public func confirmTransfer() async -> Bool {
        // Reentrancy guard: the UI already disables the button during
        // `isLoading`, but this is a domain rule (avoid duplicate transfer)
        // and shouldn't depend on presentation alone.
        guard !isLoading else { return false }
        guard let recipient = selectedRecipient, let accountBalance else { return false }

        do {
            try validateTransferAmountUseCase.validate(amount: amount, balance: accountBalance.amount)
        } catch {
            errorMessage = message(for: error)
            return false
        }

        isLoading = true
        errorMessage = nil
        do {
            receipt = try await confirmPixTransferUseCase.execute(
                recipient: recipient,
                amount: amount,
                message: message.isEmpty ? nil : message
            )
        } catch {
            errorMessage = message(for: error)
        }
        isLoading = false
        return true
    }

    /// Clears amount, message, and receipt, but keeps the recipient — used
    /// by "Repetir para {nome}" on the confirmation screen.
    public func startNewTransfer(keepingRecipient recipient: PixRecipient) {
        selectedRecipient = recipient
        typedAmountDigits = ""
        message = ""
        receipt = nil
        errorMessage = nil
    }

    /// Fully resets the flow — used by "Voltar ao início".
    public func resetFlow() {
        selectedRecipient = nil
        typedAmountDigits = ""
        message = ""
        receipt = nil
        errorMessage = nil
        searchQuery = ""
    }

    private func message(for error: Error) -> String {
        (error as? PixError)?.errorDescription ?? PixError.unknown.errorDescription ?? "Algo deu errado."
    }
}
