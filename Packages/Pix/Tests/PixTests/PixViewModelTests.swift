import XCTest
@testable import Pix

@MainActor
final class PixViewModelTests: XCTestCase {
    private func makeSUT(repository: PixRepositoryStub = PixRepositoryStub()) -> PixViewModel {
        PixViewModel(
            fetchRecentRecipientsUseCase: DefaultFetchRecentRecipientsUseCase(repository: repository),
            fetchAccountBalanceUseCase: DefaultFetchAccountBalanceUseCase(repository: repository),
            validateTransferAmountUseCase: DefaultValidateTransferAmountUseCase(),
            confirmPixTransferUseCase: DefaultConfirmPixTransferUseCase(repository: repository)
        )
    }

    // MARK: - loadInitialData

    func test_loadInitialData_whenRepositorySucceeds_populatesRecipientsAndBalance() async {
        let repository = PixRepositoryStub()
        repository.recipientsResult = .success([.stub()])
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 4120.58))
        let sut = makeSUT(repository: repository)

        await sut.loadInitialData()

        XCTAssertEqual(sut.recentRecipients, [.stub()])
        XCTAssertEqual(sut.accountBalance, PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 4120.58))
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadInitialData_whenRepositoryFails_setsErrorMessage() async {
        let repository = PixRepositoryStub()
        repository.recipientsResult = .failure(PixError.network)
        let sut = makeSUT(repository: repository)

        await sut.loadInitialData()

        XCTAssertEqual(sut.errorMessage, PixError.network.errorDescription)
        XCTAssertTrue(sut.recentRecipients.isEmpty)
    }

    func test_loadInitialData_whenRepositoryThrowsNonPixError_fallsBackToGenericMessage() async {
        struct UnmappedError: Error {}
        let repository = PixRepositoryStub()
        repository.recipientsResult = .failure(UnmappedError())
        let sut = makeSUT(repository: repository)

        await sut.loadInitialData()

        // Hoje só `PixRepositoryImpl` real mapeará `Core.NetworkError` para
        // `PixError` — até lá, qualquer erro não reconhecido cai no fallback
        // genérico. Este teste documenta esse comportamento.
        XCTAssertEqual(sut.errorMessage, PixError.unknown.errorDescription)
    }

    // MARK: - Busca de destinatários (filteredRecipients)

    func test_filteredRecipients_withEmptyQuery_returnsAllRecipients() async {
        let repository = PixRepositoryStub()
        repository.recipientsResult = .success([.stub(id: "1", name: "Ana Souza"), .stub(id: "2", name: "Rafael Mota")])
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()

        XCTAssertEqual(sut.filteredRecipients.map(\.id), ["1", "2"])
    }

    func test_filteredRecipients_matchingByNameCaseInsensitive_returnsOnlyMatch() async {
        let repository = PixRepositoryStub()
        repository.recipientsResult = .success([.stub(id: "1", name: "Ana Souza"), .stub(id: "2", name: "Rafael Mota")])
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()

        sut.searchQuery = "ana"

        XCTAssertEqual(sut.filteredRecipients.map(\.id), ["1"])
    }

    func test_filteredRecipients_matchingByKeyMasked_returnsMatch() async {
        let recipient = PixRecipient(
            id: "1",
            name: "Ana Souza",
            initials: "AS",
            bankName: "Banco Exemplo",
            keyMasked: "***.456.789-**"
        )
        let repository = PixRepositoryStub()
        repository.recipientsResult = .success([recipient])
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()

        sut.searchQuery = "456.789"

        XCTAssertEqual(sut.filteredRecipients, [recipient])
    }

    func test_filteredRecipients_withNoMatch_returnsEmptyArray() async {
        let repository = PixRepositoryStub()
        repository.recipientsResult = .success([.stub()])
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()

        sut.searchQuery = "não existe na lista"

        XCTAssertTrue(sut.filteredRecipients.isEmpty)
    }

    // MARK: - Seleção de destinatário

    func test_selectRecipient_setsSelectedRecipientAndClearsError() {
        let sut = makeSUT()
        sut.errorMessage = "erro anterior"

        sut.selectRecipient(.stub())

        XCTAssertEqual(sut.selectedRecipient, .stub())
        XCTAssertNil(sut.errorMessage)
    }

    func test_changeRecipient_clearsSelectionAmountAndMessage() {
        let sut = makeSUT()
        sut.selectRecipient(.stub())
        sut.appendAmountDigit("5")
        sut.message = "obrigado"

        sut.changeRecipient()

        XCTAssertNil(sut.selectedRecipient)
        XCTAssertEqual(sut.amount, 0)
        XCTAssertEqual(sut.message, "")
    }

    func test_selectRecipient_whenPreviousAmountAndMessageExist_clearsThemForTheNewRecipient() {
        // Reproduz o cenário de swipe-back: usuário digitou um valor para um
        // destinatário, voltou sem tocar em "Trocar" e selecionou outro.
        let sut = makeSUT()
        sut.selectRecipient(.stub(id: "1", name: "Ana Souza"))
        "25000".forEach { sut.appendAmountDigit(String($0)) }
        sut.message = "obrigado"

        sut.selectRecipient(.stub(id: "2", name: "Rafael Mota"))

        XCTAssertEqual(sut.selectedRecipient?.id, "2")
        XCTAssertEqual(sut.amount, 0)
        XCTAssertEqual(sut.message, "")
        XCTAssertNil(sut.receipt)
    }

    // MARK: - Validação de valor

    func test_confirmTransfer_withZeroAmount_setsInvalidAmountErrorAndDoesNotSubmit() async {
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000))
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        sut.selectRecipient(.stub())
        // typedAmountDigits vazio -> amount == 0

        let didSubmit = await sut.confirmTransfer()

        XCTAssertFalse(didSubmit)
        XCTAssertEqual(sut.errorMessage, PixError.invalidAmount.errorDescription)
        XCTAssertEqual(repository.confirmTransferCallCount, 0)
    }

    func test_confirmTransfer_withAmountAboveBalance_setsInsufficientBalanceErrorAndDoesNotSubmit() async {
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 100))
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        sut.selectRecipient(.stub())
        "50000".forEach { sut.appendAmountDigit(String($0)) } // R$ 500,00 > saldo de R$ 100,00

        let didSubmit = await sut.confirmTransfer()

        XCTAssertFalse(didSubmit)
        XCTAssertEqual(sut.errorMessage, PixError.insufficientBalance.errorDescription)
        XCTAssertEqual(repository.confirmTransferCallCount, 0)
    }

    func test_confirmTransfer_withAmountEqualToBalance_submitsSuccessfully() async {
        // Caso de limite: a regra é "valor > 0 e <= saldo" (plan.md), então
        // valor == saldo deve ser aceito, não rejeitado.
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 100))
        repository.confirmResult = .success(
            PixTransferReceipt(
                recipient: .stub(),
                amount: 100,
                sourceAccountLabel: "CC ·1234",
                bankName: "Banco Exemplo",
                transactionId: "E0001",
                dateLabel: "hoje"
            )
        )
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        sut.selectRecipient(.stub())
        "10000".forEach { sut.appendAmountDigit(String($0)) } // R$ 100,00 == saldo

        let didSubmit = await sut.confirmTransfer()

        XCTAssertTrue(didSubmit)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(repository.confirmTransferCallCount, 1)
    }

    func test_confirmTransfer_withoutSelectedRecipient_returnsFalseAndDoesNotCallRepository() async {
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000))
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        "25000".forEach { sut.appendAmountDigit(String($0)) }
        // Nenhum destinatário selecionado.

        let didSubmit = await sut.confirmTransfer()

        XCTAssertFalse(didSubmit)
        XCTAssertEqual(repository.confirmTransferCallCount, 0)
    }

    func test_confirmTransfer_withoutLoadedBalance_returnsFalseAndDoesNotCallRepository() async {
        let repository = PixRepositoryStub()
        let sut = makeSUT(repository: repository)
        // loadInitialData() não foi chamado -> accountBalance == nil.
        sut.selectRecipient(.stub())
        "25000".forEach { sut.appendAmountDigit(String($0)) }

        let didSubmit = await sut.confirmTransfer()

        XCTAssertFalse(didSubmit)
        XCTAssertEqual(repository.confirmTransferCallCount, 0)
    }

    func test_confirmTransfer_calledWhileAlreadyInFlight_callsRepositoryOnlyOnce() async {
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000))
        repository.confirmResult = .success(
            PixTransferReceipt(
                recipient: .stub(),
                amount: 250,
                sourceAccountLabel: "CC ·1234",
                bankName: "Banco Exemplo",
                transactionId: "E0002",
                dateLabel: "hoje"
            )
        )
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        sut.selectRecipient(.stub())
        "25000".forEach { sut.appendAmountDigit(String($0)) }

        async let first = sut.confirmTransfer()
        async let second = sut.confirmTransfer()
        let results = await [first, second]

        // Exatamente uma das duas chamadas deve ter sido a que efetivamente
        // enviou ao repositório — a outra deve ter sido barrada pelo guard
        // de reentrância (`!isLoading`), nunca as duas ao mesmo tempo.
        XCTAssertEqual(repository.confirmTransferCallCount, 1)
        XCTAssertEqual(results.filter { $0 }.count, 1)
    }

    func test_canConfirmTransfer_whileTransferIsInFlight_returnsFalse() async {
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000))
        repository.confirmDelayNanoseconds = 100_000_000 // 100ms
        repository.confirmResult = .success(
            PixTransferReceipt(
                recipient: .stub(),
                amount: 250,
                sourceAccountLabel: "CC ·1234",
                bankName: "Banco Exemplo",
                transactionId: "E0003",
                dateLabel: "hoje"
            )
        )
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        sut.selectRecipient(.stub())
        "25000".forEach { sut.appendAmountDigit(String($0)) }
        XCTAssertTrue(sut.canConfirmTransfer)

        let task = Task { await sut.confirmTransfer() }
        try? await Task.sleep(nanoseconds: 20_000_000) // 20ms: depois de isLoading=true, antes dos 100ms de "rede"

        XCTAssertTrue(sut.isLoading)
        XCTAssertFalse(sut.canConfirmTransfer)

        _ = await task.value
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.canConfirmTransfer, "após concluir, deve voltar a permitir uma nova tentativa")
    }

    // MARK: - Confirmação

    func test_confirmTransfer_whenValidAndRepositorySucceeds_setsReceiptAndReturnsTrue() async {
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000))
        let expectedReceipt = PixTransferReceipt(
            recipient: .stub(),
            amount: 250,
            sourceAccountLabel: "CC ·1234",
            bankName: "Banco Exemplo",
            transactionId: "E1234·0812",
            dateLabel: "12 ago 2026, 14:32"
        )
        repository.confirmResult = .success(expectedReceipt)
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        sut.selectRecipient(.stub())
        "25000".forEach { sut.appendAmountDigit(String($0)) } // R$ 250,00

        let didSubmit = await sut.confirmTransfer()

        XCTAssertTrue(didSubmit)
        XCTAssertEqual(sut.receipt, expectedReceipt)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_confirmTransfer_whenRepositoryFails_setsErrorMessageButStillReturnsTrue() async {
        let repository = PixRepositoryStub()
        repository.balanceResult = .success(PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000))
        repository.confirmResult = .failure(PixError.network)
        let sut = makeSUT(repository: repository)
        await sut.loadInitialData()
        sut.selectRecipient(.stub())
        "25000".forEach { sut.appendAmountDigit(String($0)) }

        let didSubmit = await sut.confirmTransfer()

        // O Coordinator ainda deve navegar para a tela de resultado, que
        // exibe o erro (ver plan.md: tela de Resultado cobre sucesso e erro).
        XCTAssertTrue(didSubmit)
        XCTAssertNil(sut.receipt)
        XCTAssertEqual(sut.errorMessage, PixError.network.errorDescription)
    }

    // MARK: - Repetir / resetar fluxo

    func test_startNewTransfer_keepsRecipientButClearsAmountMessageAndReceipt() {
        let sut = makeSUT()
        sut.selectRecipient(.stub())
        sut.message = "obrigado"

        sut.startNewTransfer(keepingRecipient: .stub())

        XCTAssertEqual(sut.selectedRecipient, .stub())
        XCTAssertEqual(sut.amount, 0)
        XCTAssertEqual(sut.message, "")
        XCTAssertNil(sut.receipt)
    }

    func test_resetFlow_clearsAllState() {
        let sut = makeSUT()
        sut.selectRecipient(.stub())
        sut.searchQuery = "ana"
        sut.message = "obrigado"

        sut.resetFlow()

        XCTAssertNil(sut.selectedRecipient)
        XCTAssertEqual(sut.amount, 0)
        XCTAssertEqual(sut.message, "")
        XCTAssertNil(sut.receipt)
        XCTAssertEqual(sut.searchQuery, "")
    }
}
