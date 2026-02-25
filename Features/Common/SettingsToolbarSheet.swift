import SwiftUI

private struct SettingsToolbarNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MyPageView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("마이페이지")
                }
            }
    }
}

extension View {
    func settingsToolbarNavigation() -> some View {
        modifier(SettingsToolbarNavigationModifier())
    }
}
