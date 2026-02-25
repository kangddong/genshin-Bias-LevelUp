import XCTest
@testable import MyBiasLevelUp

final class DeviceCalendarTests: XCTestCase {
    func testWeekdayUsesDeviceCalendarTimezone() {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 25
        components.hour = 0
        components.minute = 30
        components.timeZone = TimeZone(identifier: "Asia/Seoul")

        let date = Calendar(identifier: .gregorian).date(from: components)!

        var deviceCalendar = Calendar(identifier: .gregorian)
        deviceCalendar.timeZone = TimeZone(identifier: "Asia/Seoul")!

        let weekday = DeviceCalendar.weekday(for: date, calendar: deviceCalendar)

        XCTAssertEqual(weekday, .wednesday)
    }
}
