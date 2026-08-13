import SwiftUI

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
        .background(PixTheme.background)
        .navigationTitle("Pix")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func recipientCard(_ recipient: PixRecipient) -> some View {
        HStack(spacing: 12) {
            RecipientAvatarView(initials: recipient.initials)

            VStack(alignment: .leading, spacing: 2) {
                Text(recipient.name)
                    .font(.body.weight(.semibold))
                Text("\(recipient.bankName) · \(recipient.keyMasked)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Trocar") {
                viewModel.changeRecipient()
                onChangeRecipient()
            }
            .font(.subheadline.weight(.semibold))
            .frame(minHeight: PixTheme.minimumTapTarget)
            .accessibilityHint("Volta para a tela de seleção de destinatário")
        }
        .padding(16)
        .background(PixTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quanto você quer enviar?")
                .font(.title3.weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.formattedAmount)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .accessibilityLabel("Valor: \(viewModel.formattedAmount)")

            if let accountBalance = viewModel.accountBalance {
                Text("Saldo em conta: \(viewModel.formattedBalance)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                valueColor: viewModel.message.isEmpty ? PixTheme.primary : .primary,
                valueWeight: viewModel.message.isEmpty ? .medium : .regular
            )
        }
        .background(PixTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var confirmButton: some View {
        Button {
            Task {
                let didSubmit = await viewModel.confirmTransfer()
                if didSubmit {
                    onTransferConfirmed()
                }
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text("Transferir \(viewModel.formattedAmount)")
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: PixTheme.minimumTapTarget)
        }
        .buttonStyle(.borderedProminent)
        .tint(PixTheme.primary)
        .disabled(!viewModel.canConfirmTransfer || viewModel.isLoading)
        .accessibilityHint(
            viewModel.canConfirmTransfer
                ? "Confirma a transferência de \(viewModel.formattedAmount)"
                : "Informe um valor válido para habilitar"
        )
    }
}
