import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    let schedule: DomainSchedule?
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    CharacterImageView(localImagePath: character.localImage, imageURLs: character.imageCandidates, size: 108)

                    Spacer()

                    Button(isSelected ? "추적 해제" : "추적하기", action: onToggle)
                        .buttonStyle(.borderedProminent)
                }

                Text(character.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(character.element.displayName) / \(character.nation.displayName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("특성 재료")
                        .font(.headline)

                    if let schedule {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(schedule.materialName)
                                .font(.body)
                            Text(weekdayText(schedule.weekdays))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        Text("재료 정보를 찾을 수 없습니다.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("자세히 보기")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func weekdayText(_ weekdays: [WeekdayType]) -> String {
        let dayText = WeekdayType.ordered.filter { weekdays.contains($0) }.map(\.shortName).joined(separator: "/")
        return "비경 요일: \(dayText)"
    }
}
