import SwiftUI
import SuperAppDesignSystem

/// Tela 1 de 3 — "Para quem você vai enviar?"
/// Espelha o protótipo em design/images/pix-depois.png (tela 1).
public struct SelectRecipientView: View {
    @ObservedObject private var viewModel: PixViewModel
    private let onRecipientSelected: () -> Void

    public init(viewModel: PixViewModel, onRecipientSelected: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onRecipientSelected = onRecipientSelected
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Para quem você vai enviar?")
                    .dsFont(DSFont.largeTitle)
                    .accessibilityAddTraits(.isHeader)

                searchField

                HStack(spacing: 12) {
                    actionButton(title: "Copia e Cola", systemImage: "doc.on.clipboard")
                    actionButton(title: "QR Code", systemImage: "qrcode")
                }

                recentsSection

                Text("O tipo de chave é identificado automaticamente.")
                    .dsFont(DSFont.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(20)
        }
        .background(DSColor.background)
        .navigationTitle("Pix")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadInitialData()
        }
        .overlay {
            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
                    .padding(.horizontal, 20)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 8)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Nome, CPF, celular ou chave", text: $viewModel.searchQuery)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .accessibilityLabel("Nome, CPF, celular ou chave Pix")
        }
        .padding(.horizontal, 16)
        .frame(minHeight: PixTheme.minimumTapTarget)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(DSColor.primary, lineWidth: 1.5)
        )
    }

    private func actionButton(title: String, systemImage: String) -> some View {
        Button {
            // Fora do escopo deste scaffold: leitura de área de transferência / QR code.
        } label: {
            Label(title, systemImage: systemImage)
                .dsFont(DSFont.bodyEmphasized)
                .frame(maxWidth: .infinity)
                .frame(minHeight: PixTheme.minimumTapTarget)
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(DSColor.separator, lineWidth: 1)
        )
    }

    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENTES")
                .dsFont(DSFont.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityAddTraits(.isHeader)

            if viewModel.isLoading && viewModel.recentRecipients.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.filteredRecipients) { recipient in
                        Button {
                            viewModel.selectRecipient(recipient)
                            onRecipientSelected()
                        } label: {
                            RecipientRow(recipient: recipient)
                        }
                        .buttonStyle(.plain)

                        if recipient.id != viewModel.filteredRecipients.last?.id {
                            Divider()
                        }
                    }
                }
                .background(DSColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

private struct RecipientRow: View {
    let recipient: PixRecipient

    var body: some View {
        HStack(spacing: 12) {
            RecipientAvatarView(initials: recipient.initials)

            VStack(alignment: .leading, spacing: 2) {
                Text(recipient.name)
                    .dsFont(DSFont.body)
                    .fontWeight(.semibold)
                if let lastTransactionLabel = recipient.lastTransactionLabel {
                    Text("\(recipient.bankName) · \(lastTransactionLabel)")
                        .dsFont(DSFont.callout)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(minHeight: PixTheme.minimumTapTarget)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(recipient.name), \(recipient.bankName)")
        .accessibilityHint("Toque para selecionar este destinatário")
    }
}
