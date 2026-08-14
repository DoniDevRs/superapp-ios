import SwiftUI
import Core
import SuperAppDesignSystem

/// Tela 3 de 3 — feedback de sucesso ou erro após a confirmação. Espelha o
/// protótipo em design/images/pix-depois.png (tela 3, fundo azul de sucesso).
public struct ConfirmationView: View {
    @ObservedObject private var viewModel: PixViewModel
    private let onFinish: () -> Void
    private let onRepeat: () -> Void

    public init(
        viewModel: PixViewModel,
        onFinish: @escaping () -> Void,
        onRepeat: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onFinish = onFinish
        self.onRepeat = onRepeat
    }

    public var body: some View {
        Group {
            if let receipt = viewModel.receipt {
                successContent(receipt)
            } else {
                errorContent
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Sucesso

    private func successContent(_ receipt: PixTransferReceipt) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(DSColor.textOnPrimary)
                        .accessibilityHidden(true)

                    Text("Pix enviado")
                        .dsFont(DSFont.title)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.9))

                    Text(CurrencyFormatter.string(from: receipt.amount))
                        .dsFont(DSFont.displayValue)
                        .foregroundStyle(DSColor.textOnPrimary)

                    VStack(spacing: 4) {
                        Text("para \(receipt.recipient.name)")
                            .dsFont(DSFont.body)
                            .fontWeight(.semibold)
                        Text(receipt.dateLabel)
                            .dsFont(DSFont.callout)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Pix enviado. \(CurrencyFormatter.string(from: receipt.amount)) para \(receipt.recipient.name), em \(receipt.dateLabel)."
                )

                VStack(spacing: 0) {
                    PixDetailRow(label: "Banco", value: receipt.bankName, labelColor: .white.opacity(0.7), valueColor: DSColor.textOnPrimary)
                    Divider().overlay(.white.opacity(0.2))
                    PixDetailRow(label: "De", value: receipt.sourceAccountLabel, labelColor: .white.opacity(0.7), valueColor: DSColor.textOnPrimary)
                    Divider().overlay(.white.opacity(0.2))
                    PixDetailRow(label: "ID", value: receipt.transactionId, labelColor: .white.opacity(0.7), valueColor: DSColor.textOnPrimary)
                }
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(spacing: 12) {
                    Button {
                        // Fora do escopo deste scaffold: compartilhamento de comprovante.
                    } label: {
                        Text("Compartilhar comprovante")
                            .dsFont(DSFont.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColor.primary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: PixTheme.minimumTapTarget)
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button {
                        onFinish()
                    } label: {
                        Text("Voltar ao início")
                            .dsFont(DSFont.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColor.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: PixTheme.minimumTapTarget)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.6), lineWidth: 1.5)
                    )

                    Button("Repetir para \(receipt.recipient.name)") {
                        onRepeat()
                    }
                    .dsFont(DSFont.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(DSColor.textOnPrimary)
                    .frame(minHeight: PixTheme.minimumTapTarget)
                }
            }
            .padding(24)
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.primary)
        .foregroundStyle(DSColor.textOnPrimary)
    }

    // MARK: - Erro

    private var errorContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(PixTheme.error)
                .accessibilityHidden(true)

            Text("Não foi possível enviar o Pix")
                .dsFont(DSFont.title)
                .accessibilityAddTraits(.isHeader)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .dsFont(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(
                "Tentar novamente",
                accessibilityHint: "Tenta enviar o Pix novamente"
            ) {
                Task { await viewModel.confirmTransfer() }
            }

            Button("Voltar ao início") {
                onFinish()
            }
            .frame(minHeight: PixTheme.minimumTapTarget)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.background)
        .accessibilityElement(children: .contain)
    }
}
