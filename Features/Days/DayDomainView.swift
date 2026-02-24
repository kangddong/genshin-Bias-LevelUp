import SwiftUI

private enum DayDisplayScope: String, CaseIterable, Identifiable {
    case selected
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .selected: return "선택한 대상"
        case .all: return "전체"
        }
    }
}

struct DayDomainView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedDay: WeekdayType = ServerCalendar.weekday()
    @State private var scope: DayDisplayScope = .selected

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("요일", selection: $selectedDay) {
                        ForEach(WeekdayType.ordered) { day in
                            Text(day.shortName).tag(day)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("표시 대상", selection: $scope) {
                        ForEach(DayDisplayScope.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    sectionHeader(title: "캐릭터 육성", count: availableCharacters.count)
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(availableCharacters) { character in
                            CharacterCardView(
                                character: character,
                                isSelected: store.selection.selectedCharacterIDs.contains(character.id),
                                onToggle: { store.toggleCharacter(character.id) }
                            )
                        }
                    }

                    sectionHeader(title: "무기 돌파", count: availableWeapons.count)
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(availableWeapons) { weapon in
                            WeaponCardView(
                                weapon: weapon,
                                isSelected: store.selection.selectedWeaponIDs.contains(weapon.id),
                                onToggle: { store.toggleWeapon(weapon.id) }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("요일 비경")
        }
    }

    private var availableCharacters: [Character] {
        switch scope {
        case .selected:
            return store.availabilityService.availableCharacters(
                on: selectedDay,
                catalog: store.catalog,
                selectedIDs: store.selection.selectedCharacterIDs
            )
        case .all:
            return store.availabilityService.availableCharacters(on: selectedDay, catalog: store.catalog)
        }
    }

    private var availableWeapons: [Weapon] {
        switch scope {
        case .selected:
            return store.availabilityService.availableWeapons(
                on: selectedDay,
                catalog: store.catalog,
                selectedIDs: store.selection.selectedWeaponIDs
            )
        case .all:
            return store.availabilityService.availableWeapons(on: selectedDay, catalog: store.catalog)
        }
    }

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text("\(count)개")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
