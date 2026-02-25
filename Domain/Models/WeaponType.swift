import Foundation

enum WeaponType: String, Codable, CaseIterable, Identifiable, Sendable {
    case sword
    case claymore
    case polearm
    case catalyst
    case bow

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sword: return "한손검"
        case .claymore: return "양손검"
        case .polearm: return "장병기"
        case .catalyst: return "법구"
        case .bow: return "활"
        }
    }

    var symbolName: String {
        switch self {
        case .sword: return "sword"
        case .claymore: return "hammer"
        case .polearm: return "figure.fencing"
        case .catalyst: return "sparkles"
        case .bow: return "scope"
        }
    }
}

enum WeaponFilterMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case all
    case sword
    case claymore
    case polearm
    case catalyst
    case bow

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "전체"
        case .sword: return "한손검"
        case .claymore: return "양손검"
        case .polearm: return "장병기"
        case .catalyst: return "법구"
        case .bow: return "활"
        }
    }

    func contains(_ weapon: Weapon) -> Bool {
        guard let targetType else { return true }
        return weapon.type == targetType
    }

    private var targetType: WeaponType? {
        switch self {
        case .all: return nil
        case .sword: return .sword
        case .claymore: return .claymore
        case .polearm: return .polearm
        case .catalyst: return .catalyst
        case .bow: return .bow
        }
    }
}
