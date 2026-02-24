import SwiftUI

struct CharacterCardView: View {
    let character: Character
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(character.name)
                    .font(.headline)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }

            Text("\(character.element.displayName) · \(character.nation.displayName)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button(isSelected ? "추적 해제" : "추적하기", action: onToggle)
                .font(.caption)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
