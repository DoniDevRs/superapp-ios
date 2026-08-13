import Foundation
import Core

/// Estado observável do fluxo completo de transferência via Pix.
///
/// Este ViewModel é único e compartilhado pelas 3 telas do fluxo
/// (`SelectRecipientView` -> `ReviewPaymentView` -> `ConfirmationView`) — o
/// `PixCoordinator` cria uma instância e injeta a mesma referência em cada
/// tela, então o estado (destinatário selecionado, valor, comprovante)
/// atravessa a navegação sem precisar ser retransmitido manualmente entre
/// ViewModels por tela.
///
/// Conversa apenas com Use Cases (nunca diretamente com `PixRepository` ou
/// com networking), conforme a regra de Clean Architecture do projeto.
@MainActor
public final class PixViewModel: ObservableObject {
    // MARK: Seleção de destinatário

    @Published public var searchQuery: String = ""
    @Published public private(set) var recentRecipients: [PixRecipient] = []
    @Published public private(set) var selectedRecipient: PixRecipient?

    // MARK: Valor e revisão

    @Published public var typedAmountDigits: String = ""
    @Published public private(set) var accountBalance: PixAccountBalance?
    @Published public var message: String = ""

    // MARK: Confirmação

    @Published public private(set) var receipt: PixTransferReceipt?

    // MARK: Estado transversal

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

    /// Seleciona um destinatário e reseta valor/mensagem/comprovante — o
    /// estado de uma seleção anterior nunca deve vazar para uma nova
    /// seleção, independentemente de como o usuário chegou de volta a esta
    /// tela (toque em "Trocar" ou gesto de swipe-back do sistema).
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

    /// Executa a confirmação da transferência.
    ///
    /// Retorna `true` quando a submissão chegou a ser enviada ao Use Case
    /// (sucesso ou falha de rede/servidor) — nesse caso o Coordinator deve
    /// navegar para `ConfirmationView`, que exibe sucesso ou erro. Retorna
    /// `false` quando a validação local falhou antes de qualquer chamada
    /// (ex.: valor acima do saldo) — nesse caso a tela atual permanece e
    /// mostra o erro inline, sem navegar.
    @discardableResult
    public func confirmTransfer() async -> Bool {
        // Guard de reentrância: a UI já desabilita o botão durante
        // `isLoading`, mas essa é uma regra de domínio (evitar transferência
        // duplicada) e não deve depender só da apresentação.
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

    /// Limpa valor, mensagem e comprovante, mas mantém o destinatário — usado
    /// por "Repetir para {nome}" na tela de confirmação.
    public func startNewTransfer(keepingRecipient recipient: PixRecipient) {
        selectedRecipient = recipient
        typedAmountDigits = ""
        message = ""
        receipt = nil
        errorMessage = nil
    }

    /// Reseta o fluxo por completo — usado por "Voltar ao início".
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
