import Foundation

// DTOs that mirror the lounaat.info JSON responses exactly.

struct LounaatRestaurant: Decodable {
    let id: String
    let name: String
    let lat: String
    let lng: String
    let distance: String?
    let address: String
    let rating: String?
    let url: String?
    let slug: String?
    let menuItems: [LounaatMenuItem]
    let lunchTime: LounaatLunchTime?       // from /api/near
    let lunchTimes: [LounaatLunchTimeRange]? // from /api/restaurant
    let offers: [LounaatOffer]?
}

struct LounaatMenuItem: Decodable {
    let item: String
    let price: String?
    let info: String?
    let dietinfo: [String]?
    // Only present in /api/restaurant — bitmask: Mon=1, Tue=2, Wed=4, Thu=8, Fri=16, Sat=32, Sun=64
    let day: String?
}

struct LounaatLunchTime: Decodable {
    let start: String   // "11:00:00"
    let end: String
}

struct LounaatLunchTimeRange: Decodable {
    let days: String    // bitmask same as menuItem.day
    let start: String
    let end: String
}

struct LounaatOffer: Decodable {
    let offer: String
    let offer_text: String
    let date_end: String?
}

// MARK: - Day bitmask helpers

extension LounaatMenuItem {
    /// Returns the weekdays this item belongs to (empty = today / all days from /api/near).
    var weekdays: Set<Weekday> {
        guard let dayStr = day, let bits = Int(dayStr) else { return [] }
        return Weekday.from(bitmask: bits)
    }
}

enum Weekday: Int, CaseIterable, Identifiable {
    case monday = 1, tuesday = 2, wednesday = 4, thursday = 8, friday = 16, saturday = 32, sunday = 64
    var id: Int { rawValue }

    var localizedShort: String {
        NSLocalizedString("weekday.short.\(rawValue)", comment: "")
    }

    var localizedFull: String {
        NSLocalizedString("weekday.full.\(rawValue)", comment: "")
    }

    static var today: Weekday? {
        // Swift Calendar: 1=Sun, 2=Mon, ..., 7=Sat
        let sw = Calendar.current.component(.weekday, from: Date())
        let bit = sw == 1 ? 64 : (1 << (sw - 2))
        return Weekday(rawValue: bit)
    }

    static var workdays: [Weekday] { [.monday, .tuesday, .wednesday, .thursday, .friday] }

    static func from(bitmask: Int) -> Set<Weekday> {
        Set(allCases.filter { bitmask & $0.rawValue != 0 })
    }
}
