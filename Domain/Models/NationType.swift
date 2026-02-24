import Foundation

enum NationType: String, Codable, CaseIterable, Identifiable, Sendable {
    case mondstadt
    case liyue
    case inazuma
    case sumeru
    case fontaine
    case natlan
    case nodkrai
    case snezhnaya
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mondstadt: return "몬드"
        case .liyue: return "리월"
        case .inazuma: return "이나즈마"
        case .sumeru: return "수메르"
        case .fontaine: return "폰타인"
        case .natlan: return "나타"
        case .nodkrai: return "노드크라이"
        case .snezhnaya: return "스네즈나야"
        case .other: return "기타"
        }
    }
}
