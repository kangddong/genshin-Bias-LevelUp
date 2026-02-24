import Foundation

enum CharacterFilterMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case all
    case element
    case region

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "전체"
        case .element: return "원소"
        case .region: return "지역"
        }
    }
}

struct CharacterFilter: Codable, Equatable, Sendable {
    var mode: CharacterFilterMode
    var element: ElementType?
    var nation: NationType?

    static let `default` = CharacterFilter(mode: .all, element: nil, nation: nil)

    func apply(to characters: [Character]) -> [Character] {
        switch mode {
        case .all:
            return characters
        case .element:
            guard let element else { return characters }
            return characters.filter { $0.element == element }
        case .region:
            guard let nation else { return characters }
            return characters.filter { $0.nation == nation }
        }
    }
}
