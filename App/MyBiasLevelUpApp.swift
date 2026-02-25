import SwiftUI

@main
struct MyBiasLevelUpApp: App {
    @StateObject private var store = AppStore.makeDefault()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .task {
                    await store.loadCatalogIfNeeded()
                }
                .alert("오류", isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.errorMessage = nil } }
                )) {
                    Button("확인", role: .cancel) {}
                } message: {
                    Text(store.errorMessage ?? "")
                }
                .onChange(of: scenePhase) { newPhase in
                    guard newPhase == .active else { return }
                    Task {
                        await store.refreshNotificationStatus()
                    }
                }
        }
    }
}
