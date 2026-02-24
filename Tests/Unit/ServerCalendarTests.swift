import XCTest
@testable import MyBiasLevelUp

final class ServerCalendarTests: XCTestCase {
    func testWeekdayUsesAsiaServerTimezone() {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 24
        components.hour = 0
        components.minute = 30
        components.timeZone = TimeZone(identifier: "Asia/Seoul")

        let date = Calendar(identifier: .gregorian).date(from: components)!
        let weekday = ServerCalendar.weekday(for: date)

        XCTAssertEqual(weekday, .monday)
    }
}
