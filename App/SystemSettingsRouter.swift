import Foundation
import UIKit

@MainActor
protocol SystemSettingsRouting {
    func openAppSettings()
}

struct UIApplicationSettingsRouter: SystemSettingsRouting {
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
