import SwiftUI
import Core
import SuperAppDesignSystem

/// Screen 3 of 3 — success or error feedback after confirmation. Mirrors the
/// prototype in design/images/pix-depois.png (screen 3, blue success background).
public struct ConfirmationView: View {
    @ObservedObject private var viewModel: PixViewModel
    private let onFinish: () -> Void
    private let onRepeat: () -> Void

    /// Scales with the user's Dynamic Type — a fixed `.font(.system(size:))`
    /// wouldn't track accessibility font sizes (finding from the
    /// 2026-08-14 audit).
    @ScaledMetric(relativeTo: .largeTitle) private var statusIconSize: CGFloat = 56

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

    // MARK: - Success

    private func successContent(_ receipt: PixTransferReceipt) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: statusIconSize))
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
                        // Out of scope for this scaffold: sharing the receipt.
                    } label: {
                        Text("Compartilhar comprovante")
                            .dsFont(DSFont.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColor.primary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: PixTheme.minimumTapTarget)
                    }
                    .contentShape(Rectangle())
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
                    .contentShape(Rectangle())
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
                    .contentShape(Rectangle())
                }
            }
            .padding(24)
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.primary)
        .foregroundStyle(DSColor.textOnPrimary)
    }

    // MARK: - Error

    private var errorContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: statusIconSize))
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
            .contentShape(Rectangle())
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.background)
        .accessibilityElement(children: .contain)
    }
}
