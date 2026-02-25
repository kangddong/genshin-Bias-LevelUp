import SwiftUI

struct TrackableMaterialDetailView: View {
    let localImagePath: String?
    let imageURLs: [String]
    let title: String
    let subtitle: String
    let placeholderStyle: CharacterImageView.PlaceholderStyle
    let materialSectionTitle: String
    let schedule: DomainSchedule?
    let isSelected: Bool
    let onToggle: () -> Void
    let isFavorite: Bool
    let onToggleFavorite: (() -> Void)?

    init(
        localImagePath: String?,
        imageURLs: [String],
        title: String,
        subtitle: String,
        placeholderStyle: CharacterImageView.PlaceholderStyle = .character,
        materialSectionTitle: String = "특성 재료",
        schedule: DomainSchedule?,
        isSelected: Bool,
        onToggle: @escaping () -> Void,
        isFavorite: Bool = false,
        onToggleFavorite: (() -> Void)? = nil
    ) {
        self.localImagePath = localImagePath
        self.imageURLs = imageURLs
        self.title = title
        self.subtitle = subtitle
        self.placeholderStyle = placeholderStyle
        self.materialSectionTitle = materialSectionTitle
        self.schedule = schedule
        self.isSelected = isSelected
        self.onToggle = onToggle
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
    }

    var body: some View {
        ZStack {
            DSBackgroundLayer()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DSCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                CharacterImageView(
                                    localImagePath: localImagePath,
                                    imageURLs: imageURLs,
                                    size: 108,
                                    placeholderStyle: placeholderStyle
                                )

                                Spacer()

                                if isSelected {
                                    Button("추적 해제", action: onToggle)
                                        .buttonStyle(DSSecondaryButtonStyle())
                                } else {
                                    Button("추적하기", action: onToggle)
                                        .buttonStyle(DSPrimaryButtonStyle())
                                }
                            }

                            Text(title)
                                .font(DSTypography.section)
                                .foregroundStyle(DSColor.textPrimary)

                            Text(subtitle)
                                .font(DSTypography.body)
                                .foregroundStyle(DSColor.textSecondary)

                            if isSelected, let onToggleFavorite {
                                if isFavorite {
                                    Button("최애 해제", action: onToggleFavorite)
                                        .buttonStyle(DSSecondaryButtonStyle())
                                } else {
                                    Button("최애 설정", action: onToggleFavorite)
                                        .buttonStyle(DSPrimaryButtonStyle())
                                }
                            }
                        }
                    }

                    DSSectionHeader(title: materialSectionTitle, trailing: nil)
                    if let schedule {
                        DSCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(schedule.materialName)
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColor.textPrimary)
                                Text(weekdayText(schedule.weekdays))
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                        }
                    } else {
                        DSCard {
                            Text("재료 정보를 찾을 수 없습니다.")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("자세히 보기")
        .navigationBarTitleDisplayMode(.inline)
        .dsNavigationBar()
    }

    private func weekdayText(_ weekdays: [WeekdayType]) -> String {
        let dayText = WeekdayType.ordered
            .filter { weekdays.contains($0) }
            .map(\.shortName)
            .joined(separator: "/")
        return "비경 요일: \(dayText)"
    }
}
