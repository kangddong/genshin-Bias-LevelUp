import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    let schedule: DomainSchedule?
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        ZStack {
            DSBackgroundLayer()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DSCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                CharacterImageView(localImagePath: character.localImage, imageURLs: character.imageCandidates, size: 108)

                                Spacer()

                                if isSelected {
                                    Button("추적 해제", action: onToggle)
                                        .buttonStyle(DSSecondaryButtonStyle())
                                } else {
                                    Button("추적하기", action: onToggle)
                                        .buttonStyle(DSPrimaryButtonStyle())
                                }
                            }

                            Text(character.name)
                                .font(DSTypography.section)
                                .foregroundStyle(DSColor.textPrimary)

                            Text("\(character.element.displayName) / \(character.nation.displayName)")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                    }

                    DSSectionHeader(title: "특성 재료", trailing: nil)
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
        let dayText = WeekdayType.ordered.filter { weekdays.contains($0) }.map(\.shortName).joined(separator: "/")
        return "비경 요일: \(dayText)"
    }
}
