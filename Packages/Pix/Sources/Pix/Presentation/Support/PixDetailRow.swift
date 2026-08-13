import SwiftUI

/// Linha "rótulo à esquerda / valor à direita", reutilizada pela tela de
/// revisão (fundo claro, ex.: "De", "Quando", "Tarifa") e pela tela de
/// confirmação (fundo azul de sucesso, ex.: "Banco", "ID") — evita duplicar
/// layout e acessibilidade entre as duas telas.
struct PixDetailRow: View {
    let label: String
    let value: String
    var labelColor: Color = .secondary
    var valueColor: Color = .primary
    var valueWeight: Font.Weight = .regular

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(labelColor)
            Spacer()
            Text(value)
                .foregroundStyle(valueColor)
                .fontWeight(valueWeight)
        }
        .padding(16)
        .frame(minHeight: PixTheme.minimumTapTarget)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
