import Foundation

struct ServerCalendar {
    static let serverTimeZone = TimeZone(identifier: "Asia/Shanghai") ?? TimeZone(secondsFromGMT: 8 * 3600)!

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = serverTimeZone
        return calendar
    }

    static func weekday(for date: Date = Date()) -> WeekdayType {
        let weekday = calendar.component(.weekday, from: date)
        return WeekdayType.from(calendarWeekday: weekday)
    }
}
