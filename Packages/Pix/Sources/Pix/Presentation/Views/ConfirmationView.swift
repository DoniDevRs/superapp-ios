import SwiftUI
import Core

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
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)

                    Text("Pix enviado")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))

                    Text(CurrencyFormatter.string(from: receipt.amount))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    VStack(spacing: 4) {
                        Text("para \(receipt.recipient.name)")
                            .font(.body.weight(.semibold))
                        Text(receipt.dateLabel)
                            .font(.subheadline)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Pix enviado. \(CurrencyFormatter.string(from: receipt.amount)) para \(receipt.recipient.name), em \(receipt.dateLabel)."
                )

                VStack(spacing: 0) {
                    PixDetailRow(label: "Banco", value: receipt.bankName, labelColor: .white.opacity(0.7), valueColor: .white)
                    Divider().overlay(.white.opacity(0.2))
                    PixDetailRow(label: "De", value: receipt.sourceAccountLabel, labelColor: .white.opacity(0.7), valueColor: .white)
                    Divider().overlay(.white.opacity(0.2))
                    PixDetailRow(label: "ID", value: receipt.transactionId, labelColor: .white.opacity(0.7), valueColor: .white)
                }
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(spacing: 12) {
                    Button {
                        // Fora do escopo deste scaffold: compartilhamento de comprovante.
                    } label: {
                        Text("Compartilhar comprovante")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(PixTheme.primary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: PixTheme.minimumTapTarget)
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button {
                        onFinish()
                    } label: {
                        Text("Voltar ao início")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
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
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(minHeight: PixTheme.minimumTapTarget)
                }
            }
            .padding(24)
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PixTheme.primary)
        .foregroundStyle(.white)
    }

    // MARK: - Erro

    private var errorContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(PixTheme.error)
                .accessibilityHidden(true)

            Text("Não foi possível enviar o Pix")
                .font(.title3.weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await viewModel.confirmTransfer() }
            } label: {
                Text("Tentar novamente")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: PixTheme.minimumTapTarget)
            }
            .buttonStyle(.borderedProminent)
            .tint(PixTheme.primary)

            Button("Voltar ao início") {
                onFinish()
            }
            .frame(minHeight: PixTheme.minimumTapTarget)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PixTheme.background)
        .accessibilityElement(children: .contain)
    }
}
