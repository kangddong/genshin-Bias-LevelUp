import Foundation

struct DeviceCalendar {
    static func weekday(for date: Date = Date(), calendar: Calendar = .current) -> WeekdayType {
        let weekday = calendar.component(.weekday, from: date)
        return WeekdayType.from(calendarWeekday: weekday)
    }
}
