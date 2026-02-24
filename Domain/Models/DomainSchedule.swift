import Foundation

enum MaterialKind: String, Codable, Sendable {
    case character
    case weapon
}

struct DomainSchedule: Codable, Hashable, Sendable {
    let materialId: String
    let materialName: String
    let domainName: String
    let weekdays: [WeekdayType]
    let kind: MaterialKind
}
