import SwiftUI
import SuperAppDesignSystem

/// Tela 2 de 3 — destinatário selecionado + "Quanto você quer enviar?" +
/// resumo revisável antes de confirmar. Espelha o protótipo em
/// design/images/pix-depois.png (tela 2), que junta valor e revisão em uma
/// única tela.
public struct ReviewPaymentView: View {
    @ObservedObject private var viewModel: PixViewModel
    private let onChangeRecipient: () -> Void
    private let onTransferConfirmed: () -> Void

    public init(
        viewModel: PixViewModel,
        onChangeRecipient: @escaping () -> Void,
        onTransferConfirmed: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onChangeRecipient = onChangeRecipient
        self.onTransferConfirmed = onTransferConfirmed
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let recipient = viewModel.selectedRecipient {
                    recipientCard(recipient)
                }

                amountSection

                detailsSection

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                NumericKeypad(
                    onDigit: { viewModel.appendAmountDigit($0) },
                    onDelete: { viewModel.removeLastAmountDigit() }
                )

                confirmButton
            }
            .padding(20)
        }
        .background(DSColor.background)
        .navigationTitle("Pix")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func recipientCard(_ recipient: PixRecipient) -> some View {
        HStack(spacing: 12) {
            RecipientAvatarView(initials: recipient.initials)

            VStack(alignment: .leading, spacing: 2) {
                Text(recipient.name)
                    .dsFont(DSFont.body)
                    .fontWeight(.semibold)
                Text("\(recipient.bankName) · \(recipient.keyMasked)")
                    .dsFont(DSFont.callout)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer()

            Button("Trocar") {
                viewModel.changeRecipient()
                onChangeRecipient()
            }
            .dsFont(DSFont.callout)
            .fontWeight(.semibold)
            .foregroundStyle(DSColor.accent)
            .frame(minHeight: PixTheme.minimumTapTarget)
            .accessibilityHint("Volta para a tela de seleção de destinatário")
        }
        .padding(16)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quanto você quer enviar?")
                .dsFont(DSFont.title)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.formattedAmount)
                .dsFont(DSFont.displayValue)
                .accessibilityLabel("Valor: \(viewModel.formattedAmount)")

            if let accountBalance = viewModel.accountBalance {
                Text("Saldo em conta: \(viewModel.formattedBalance)")
                    .dsFont(DSFont.callout)
                    .foregroundStyle(DSColor.textSecondary)
                    .accessibilityLabel("Saldo em conta: \(viewModel.formattedBalance)")
                    .accessibilityHidden(false)
                    .id(accountBalance.sourceAccountLabel)
            }
        }
    }

    private var detailsSection: some View {
        VStack(spacing: 0) {
            PixDetailRow(label: "De", value: viewModel.accountBalance?.sourceAccountLabel ?? "—")
            Divider()
            PixDetailRow(label: "Quando", value: "Agora")
            Divider()
            PixDetailRow(label: "Tarifa", value: "Sem tarifa")
            Divider()
            PixDetailRow(
                label: "Mensagem",
                value: viewModel.message.isEmpty ? "Adicionar" : viewModel.message,
                valueColor: viewModel.message.isEmpty ? DSColor.accent : DSColor.textPrimary,
                valueWeight: viewModel.message.isEmpty ? .medium : .regular
            )
        }
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var confirmButton: some View {
        PrimaryButton(
            "Transferir \(viewModel.formattedAmount)",
            accessibilityLabel: "Transferir \(viewModel.formattedAmount)",
            accessibilityHint: viewModel.canConfirmTransfer
                ? "Confirma a transferência de \(viewModel.formattedAmount)"
                : "Informe um valor válido para habilitar",
            isLoading: viewModel.isLoading,
            isEnabled: viewModel.canConfirmTransfer
        ) {
            Task {
                let didSubmit = await viewModel.confirmTransfer()
                if didSubmit {
                    onTransferConfirmed()
                }
            }
        }
    }
}
