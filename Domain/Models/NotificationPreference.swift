import Foundation

struct NotificationTimeSlot: Codable, Equatable, Sendable, Identifiable, Hashable {
    let id: UUID
    var hour: Int
    var minute: Int

    init(id: UUID = UUID(), hour: Int, minute: Int) {
        self.id = id
        self.hour = hour
        self.minute = minute
    }
}

struct NotificationPreference: Codable, Equatable, Sendable {
    var timeSlots: [NotificationTimeSlot]
    var defaultFilter: CharacterFilter
    var lastAppOpenAt: Date?

    static let `default` = NotificationPreference(
        timeSlots: [NotificationTimeSlot(hour: 20, minute: 0)],
        defaultFilter: .default,
        lastAppOpenAt: nil
    )

    private enum CodingKeys: String, CodingKey {
        case timeSlots
        case defaultFilter
        case lastAppOpenAt

        // Legacy keys kept for backward compatibility.
        case hour
        case minute
        case enabledWeekdays
    }

    init(timeSlots: [NotificationTimeSlot], defaultFilter: CharacterFilter, lastAppOpenAt: Date? = nil) {
        self.timeSlots = timeSlots
        self.defaultFilter = defaultFilter
        self.lastAppOpenAt = lastAppOpenAt
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultFilter = try container.decodeIfPresent(CharacterFilter.self, forKey: .defaultFilter) ?? .default
        lastAppOpenAt = try container.decodeIfPresent(Date.self, forKey: .lastAppOpenAt)

        if let decodedSlots = try container.decodeIfPresent([NotificationTimeSlot].self, forKey: .timeSlots),
           !decodedSlots.isEmpty {
            timeSlots = decodedSlots
            return
        }

        let hour = try container.decodeIfPresent(Int.self, forKey: .hour) ?? 20
        let minute = try container.decodeIfPresent(Int.self, forKey: .minute) ?? 0
        timeSlots = [NotificationTimeSlot(hour: hour, minute: minute)]
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timeSlots, forKey: .timeSlots)
        try container.encode(defaultFilter, forKey: .defaultFilter)
        try container.encodeIfPresent(lastAppOpenAt, forKey: .lastAppOpenAt)
    }
}
