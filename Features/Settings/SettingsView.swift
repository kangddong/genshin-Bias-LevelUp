import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            Form {
                Section("알림") {
                    HStack {
                        Text("권한 상태")
                        Spacer()
                        Text(statusText)
                            .foregroundStyle(.secondary)
                    }

                    Button("알림 권한 요청") {
                        Task {
                            await store.requestNotificationAuthorization()
                        }
                    }

                    DatePicker(
                        "알림 시간",
                        selection: Binding(
                            get: { store.timeAsDate() },
                            set: { store.updateNotificationTime(date: $0) }
                        ),
                        displayedComponents: .hourAndMinute
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("알림 요일")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(WeekdayType.ordered) { day in
                                    TagChip(
                                        text: day.shortName,
                                        isSelected: store.preference.enabledWeekdays.contains(day),
                                        onTap: { store.toggleNotificationWeekday(day) }
                                    )
                                }
                            }
                        }
                    }
                }

                Section("기본 필터") {
                    Picker("모드", selection: filterModeBinding) {
                        ForEach(CharacterFilterMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }

                    if store.characterFilter.mode == .element {
                        Picker("원소", selection: elementBinding) {
                            ForEach(ElementType.allCases) { element in
                                Text(element.displayName).tag(Optional(element))
                            }
                        }
                    }

                    if store.characterFilter.mode == .region {
                        Picker("지역", selection: nationBinding) {
                            ForEach(NationType.allCases) { nation in
                                Text(nation.displayName).tag(Optional(nation))
                            }
                        }
                    }
                }

                Section("육성 대상") {
                    NavigationLink("무기 선택") {
                        WeaponSelectionView()
                    }

                    HStack {
                        Text("선택한 캐릭터")
                        Spacer()
                        Text("\(store.selection.selectedCharacterIDs.count)개")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("선택한 무기")
                        Spacer()
                        Text("\(store.selection.selectedWeaponIDs.count)개")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
        }
    }

    private var statusText: String {
        switch store.notificationStatus {
        case .notDetermined: return "미요청"
        case .denied: return "거부"
        case .authorized: return "허용"
        case .provisional: return "임시 허용"
        case .ephemeral: return "일시 허용"
        }
    }

    private var filterModeBinding: Binding<CharacterFilterMode> {
        Binding {
            store.characterFilter.mode
        } set: { newValue in
            var filter = store.characterFilter
            filter.mode = newValue
            switch newValue {
            case .all:
                filter.element = nil
                filter.nation = nil
            case .element:
                filter.element = filter.element ?? .anemo
                filter.nation = nil
            case .region:
                filter.nation = filter.nation ?? .mondstadt
                filter.element = nil
            }
            store.updateCharacterFilter(filter)
        }
    }

    private var elementBinding: Binding<ElementType?> {
        Binding {
            store.characterFilter.element
        } set: { value in
            var filter = store.characterFilter
            filter.element = value
            store.updateCharacterFilter(filter)
        }
    }

    private var nationBinding: Binding<NationType?> {
        Binding {
            store.characterFilter.nation
        } set: { value in
            var filter = store.characterFilter
            filter.nation = value
            store.updateCharacterFilter(filter)
        }
    }
}
