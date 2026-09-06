import Foundation

/// Pre-formatted pieces of a Date that the faces need. Computed once per redraw.
struct TimeParts {
    let hour: Int          // 0-23
    let minute: Int
    let displayHour: Int   // 1-12 or 0-23 depending on mode
    let isPM: Bool
    let use24Hour: Bool
    let weekdayShort: String   // "Fri"
    let weekdayLong: String    // "Friday"
    let monthShort: String     // "Sep"
    let monthLong: String      // "September"
    let day: Int
    let month: Int
    let dateLong: String       // "Friday, September 5"

    init(_ date: Date, use24Hour: Bool) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .day, .month, .weekday], from: date)
        hour = comps.hour ?? 0
        minute = comps.minute ?? 0
        day = comps.day ?? 1
        month = comps.month ?? 1
        isPM = hour >= 12
        self.use24Hour = use24Hour
        if use24Hour {
            displayHour = hour
        } else {
            let h = hour % 12
            displayHour = h == 0 ? 12 : h
        }
        let weekdayIndex = (comps.weekday ?? 1) - 1
        let fmt = DateFormatter()
        weekdayShort = fmt.shortWeekdaySymbols[weekdayIndex]
        weekdayLong = fmt.weekdaySymbols[weekdayIndex]
        monthShort = fmt.shortMonthSymbols[month - 1]
        monthLong = fmt.monthSymbols[month - 1]
        dateLong = "\(weekdayLong), \(monthLong) \(day)"
    }

    /// "9:41" or "09:41" (24h).
    var timeString: String {
        let h = use24Hour ? String(format: "%02d", displayHour) : String(displayHour)
        return "\(h):" + String(format: "%02d", minute)
    }

    /// Four digit slots, nil for a blank leading slot in 12-hour mode.
    var digitSlots: [Int?] {
        let h = displayHour
        let leading: Int? = (!use24Hour && h < 10) ? nil : h / 10
        return [leading, h % 10, minute / 10, minute % 10]
    }

    var meridiem: String { isPM ? "PM" : "AM" }
}
