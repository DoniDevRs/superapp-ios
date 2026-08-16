import XCTest

/// Roda a auditoria automatizada de acessibilidade da Apple
/// (`XCUIApplication.performAccessibilityAudit()`, Xcode 15+/iOS 17+) em
/// cada uma das 3 telas do fluxo Pix, navegando o caminho feliz completo:
/// SelectRecipientView -> ReviewPaymentView -> ConfirmationView.
///
/// A auditoria cobre, entre outras categorias, contraste, Dynamic Type,
/// tamanho de área de toque e descrição suficiente de elementos — as mesmas
/// dimensões da skill `accessibility-audit`, mas verificadas em tempo de
/// execução contra a árvore de acessibilidade real, não por leitura de
/// código. Sem um `issueHandler`, `performAccessibilityAudit()` lança um
/// erro (falhando o teste) se encontrar qualquer achado — este teste é um
/// gate real contra regressões, não só um relatório.
final class AccessibilityAuditUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @available(iOS 17.0, *)
    func test_accessibilityAudit_acrossFullPixFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // MARK: Tela 1 — SelectRecipientView

        let recipientRow = app.buttons["Ana Souza, Banco Exemplo"]
        XCTAssertTrue(
            recipientRow.waitForExistence(timeout: 10),
            "A linha do destinatário recente não apareceu na tela de seleção."
        )
        try app.performAccessibilityAudit()

        recipientRow.tap()

        // MARK: Tela 2 — ReviewPaymentView

        let changeRecipientButton = app.buttons["Trocar destinatário"]
        XCTAssertTrue(
            changeRecipientButton.waitForExistence(timeout: 5),
            "Não navegou para ReviewPaymentView."
        )
        try app.performAccessibilityAudit()

        // Digita um valor válido (R$ 0,01) para habilitar a confirmação.
        app.buttons["1"].tap()

        let transferButton = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Transferir'")
        ).firstMatch
        XCTAssertTrue(
            transferButton.waitForExistence(timeout: 5),
            "Botão de transferir não foi encontrado depois de digitar o valor."
        )
        transferButton.tap()

        // MARK: Tela 3 — ConfirmationView (sucesso)

        let backToStartButton = app.buttons["Voltar ao início"]
        XCTAssertTrue(
            backToStartButton.waitForExistence(timeout: 10),
            "Não navegou para ConfirmationView após confirmar a transferência."
        )
        try app.performAccessibilityAudit()
    }
}
