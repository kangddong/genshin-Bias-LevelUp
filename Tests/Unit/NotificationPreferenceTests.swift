import XCTest
@testable import MyBiasLevelUp

final class NotificationPreferenceTests: XCTestCase {
    func testDecodeLegacyPreferenceFallsBackToSingleTimeSlot() throws {
        struct LegacyNotificationPreference: Codable {
            let hour: Int
            let minute: Int
            let enabledWeekdays: Set<WeekdayType>
            let defaultFilter: CharacterFilter
        }

        let legacy = LegacyNotificationPreference(
            hour: 21,
            minute: 30,
            enabledWeekdays: [.monday, .wednesday],
            defaultFilter: .default
        )

        let data = try JSONEncoder().encode(legacy)
        let decoded = try JSONDecoder().decode(NotificationPreference.self, from: data)

        XCTAssertEqual(decoded.timeSlots.count, 1)
        XCTAssertEqual(decoded.timeSlots.first?.hour, 21)
        XCTAssertEqual(decoded.timeSlots.first?.minute, 30)
        XCTAssertEqual(decoded.defaultFilter, .default)
        XCTAssertNil(decoded.lastAppOpenAt)
    }

    func testEncodeAndDecodeTimeSlots() throws {
        let lastOpenAt = Date(timeIntervalSince1970: 1_735_689_600)
        let preference = NotificationPreference(
            timeSlots: [
                NotificationTimeSlot(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, hour: 9, minute: 0),
                NotificationTimeSlot(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, hour: 15, minute: 0)
            ],
            defaultFilter: CharacterFilter(mode: .element, element: .hydro, nation: nil),
            lastAppOpenAt: lastOpenAt
        )

        let data = try JSONEncoder().encode(preference)
        let decoded = try JSONDecoder().decode(NotificationPreference.self, from: data)

        XCTAssertEqual(decoded, preference)
    }
}
