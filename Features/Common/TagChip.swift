import SwiftUI

struct TagChip: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(DSTypography.body.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isSelected ? DSColor.primary : DSColor.panelStrong)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? DSColor.primary : DSColor.border, lineWidth: 1)
                )
                .foregroundStyle(isSelected ? Color.white : DSColor.textPrimary)
        }
        .buttonStyle(.plain)
    }
}
