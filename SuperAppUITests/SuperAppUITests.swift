import XCTest

/// Teste de regressão para o bug relatado em 2026-08-13: tocar em um
/// destinatário recente na tela de seleção não navegava para a tela de
/// revisão de pagamento. Roda no simulador via `xcodebuild test` — não
/// depende de permissões de Acessibilidade do host.
final class SuperAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_tappingRecentRecipient_navigatesToReviewPaymentScreen() throws {
        let app = XCUIApplication()
        app.launch()

        let recipientRow = app.buttons["Ana Souza, Banco Exemplo"]
        XCTAssertTrue(
            recipientRow.waitForExistence(timeout: 10),
            "A linha do destinatário recente não apareceu na tela de seleção."
        )

        recipientRow.tap()

        let changeRecipientButton = app.buttons["Trocar"]
        XCTAssertTrue(
            changeRecipientButton.waitForExistence(timeout: 5),
            "Tocar no destinatário não navegou para ReviewPaymentView (botão \"Trocar\" nunca apareceu)."
        )
    }

    /// Cobre as 3 linhas da lista de recentes, não só a primeira — o bug
    /// relatado dizia "tocar em qualquer um deles não faz nada".
    func test_tappingEachRecentRecipient_navigatesToReviewPaymentScreen() throws {
        let app = XCUIApplication()
        app.launch()

        let recipients = [
            "Ana Souza, Banco Exemplo",
            "Rafael Mota, Cooperativa",
            "Padaria Lopes, CNPJ",
        ]

        for accessibilityLabel in recipients {
            let recipientRow = app.buttons[accessibilityLabel]
            XCTAssertTrue(
                recipientRow.waitForExistence(timeout: 10),
                "Linha \"\(accessibilityLabel)\" não apareceu na tela de seleção."
            )

            recipientRow.tap()

            let changeRecipientButton = app.buttons["Trocar"]
            XCTAssertTrue(
                changeRecipientButton.waitForExistence(timeout: 5),
                "Tocar em \"\(accessibilityLabel)\" não navegou para ReviewPaymentView."
            )

            // Volta para a tela de seleção para testar a próxima linha.
            changeRecipientButton.tap()
        }
    }
}
