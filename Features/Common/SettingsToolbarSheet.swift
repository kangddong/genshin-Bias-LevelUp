import SwiftUI

private struct SettingsToolbarSheetModifier: ViewModifier {
    @State private var isSettingsPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSettingsPresented = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("설정")
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                NavigationStack {
                    SettingsView()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("닫기") {
                                    isSettingsPresented = false
                                }
                            }
                        }
                }
            }
    }
}

extension View {
    func settingsToolbarSheet() -> some View {
        modifier(SettingsToolbarSheetModifier())
    }
}
