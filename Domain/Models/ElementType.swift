import Foundation

enum ElementType: String, Codable, CaseIterable, Identifiable, Sendable {
    case anemo
    case geo
    case electro
    case dendro
    case hydro
    case pyro
    case cryo

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .anemo: return "바람"
        case .geo: return "바위"
        case .electro: return "번개"
        case .dendro: return "풀"
        case .hydro: return "물"
        case .pyro: return "불"
        case .cryo: return "얼음"
        }
    }
}
