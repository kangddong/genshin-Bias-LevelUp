import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            DSBackgroundLayer()

            List {
                Section("권한") {
                    Toggle(isOn: .constant(store.notificationStatus.isAuthorized)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("앱 알림 권한")
                            Text(permissionDescription)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                    }
                    .disabled(true)

                    permissionActionView
                }

                Section {
                    ForEach(Array(store.notificationTimeSlots.enumerated()), id: \.element.id) { index, slot in
                        DatePicker(
                            "알림 시간 \(index + 1)",
                            selection: Binding(
                                get: { store.date(for: slot) },
                                set: { store.updateNotificationTime(slotID: slot.id, date: $0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )

                        if store.notificationTimeSlots.count > 1 {
                            Button("시간 삭제", role: .destructive) {
                                store.removeNotificationTimeSlot(slot.id)
                            }
                        }
                    }

                    Button("알림 시간 추가") {
                        store.addNotificationTimeSlot()
                    }
                    .disabled(store.notificationTimeSlots.count >= 3)
                } footer: {
                    Text("하루 최대 3회까지 설정할 수 있고, 시간 간격은 최소 4시간입니다.")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("알림 설정")
        .navigationBarTitleDisplayMode(.inline)
        .dsNavigationBar()
    }

    @ViewBuilder
    private var permissionActionView: some View {
        switch store.notificationStatus {
        case .notDetermined:
            Button("알림 권한 요청") {
                Task {
                    await store.requestNotificationAuthorization()
                }
            }
        case .denied:
            Button("설정에서 허용") {
                store.openSystemSettings()
            }
        case .authorized, .provisional, .ephemeral:
            Button("시스템 설정 열기") {
                store.openSystemSettings()
            }
        }
    }

    private var permissionDescription: String {
        switch store.notificationStatus {
        case .notDetermined: return "아직 알림 권한을 요청하지 않았습니다."
        case .denied: return "알림이 거부되어 있습니다. 설정 앱에서 변경할 수 있습니다."
        case .authorized: return "알림이 허용되어 있습니다."
        case .provisional: return "알림이 임시 허용 상태입니다."
        case .ephemeral: return "알림이 일시 허용 상태입니다."
        }
    }
}
