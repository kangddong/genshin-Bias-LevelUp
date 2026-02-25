import SwiftUI

struct SelectionCheckButton: View {
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? DSColor.primary : DSColor.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

struct CardIdentitySection<Trailing: View>: View {
    let localImagePath: String?
    let imageURLs: [String]
    let title: String
    let subtitle: String
    let imageSize: CGFloat
    let placeholderStyle: CharacterImageView.PlaceholderStyle
    let subtitleLineLimit: Int
    private let trailing: () -> Trailing

    init(
        localImagePath: String?,
        imageURLs: [String],
        title: String,
        subtitle: String,
        imageSize: CGFloat,
        placeholderStyle: CharacterImageView.PlaceholderStyle = .character,
        subtitleLineLimit: Int = 1,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.localImagePath = localImagePath
        self.imageURLs = imageURLs
        self.title = title
        self.subtitle = subtitle
        self.imageSize = imageSize
        self.placeholderStyle = placeholderStyle
        self.subtitleLineLimit = subtitleLineLimit
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                CharacterImageView(
                    localImagePath: localImagePath,
                    imageURLs: imageURLs,
                    size: imageSize,
                    placeholderStyle: placeholderStyle
                )

                Spacer()

                trailing()
            }

            Text(title)
                .font(DSTypography.headline)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(2)

            Text(subtitle)
                .font(DSTypography.caption)
                .foregroundStyle(DSColor.textSecondary)
                .lineLimit(subtitleLineLimit)
        }
    }
}

extension CardIdentitySection where Trailing == EmptyView {
    init(
        localImagePath: String?,
        imageURLs: [String],
        title: String,
        subtitle: String,
        imageSize: CGFloat,
        placeholderStyle: CharacterImageView.PlaceholderStyle = .character,
        subtitleLineLimit: Int = 1
    ) {
        self.init(
            localImagePath: localImagePath,
            imageURLs: imageURLs,
            title: title,
            subtitle: subtitle,
            imageSize: imageSize,
            placeholderStyle: placeholderStyle,
            subtitleLineLimit: subtitleLineLimit,
            trailing: { EmptyView() }
        )
    }
}

struct CharacterCardView: View {
    let character: Character
    let isSelected: Bool
    let onToggle: () -> Void

    private let minCardHeight: CGFloat = 170

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 10) {
                CardIdentitySection(
                    localImagePath: character.localImage,
                    imageURLs: character.imageCandidates,
                    title: character.name,
                    subtitle: "\(character.element.displayName) · \(character.nation.displayName)",
                    imageSize: 42
                ) {
                    SelectionCheckButton(isSelected: isSelected, onTap: onToggle)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Button("추적 해제", action: onToggle)
                        .buttonStyle(DSSecondaryButtonStyle())
                } else {
                    Button("추적하기", action: onToggle)
                        .buttonStyle(DSPrimaryButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, minHeight: minCardHeight, alignment: .topLeading)
        }
    }
}
