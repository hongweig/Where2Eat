import Foundation

enum MealPeriod: String, CaseIterable, Identifiable {
    case breakfast, lunch, dinner
    var id: String { rawValue }

    var localizedName: String { NSLocalizedString("meal.\(rawValue)", comment: "") }

    var timeRange: String {
        switch self {
        case .breakfast: return "06:00–10:30"
        case .lunch:     return "11:00–14:30"
        case .dinner:    return "17:00–21:30"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch:     return "sun.max.fill"
        case .dinner:    return "moon.stars.fill"
        }
    }

    static var current: MealPeriod {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 6..<11:  return .breakfast
        case 11..<17: return .lunch
        default:      return .dinner
        }
    }
}

struct DailyMenu: Identifiable {
    let id = UUID()
    let restaurantId: String
    let date: Date
    let mealPeriod: MealPeriod
    var sections: [MenuSection]

    var isEmpty: Bool { sections.allSatisfy { $0.items.isEmpty } }
}

struct MenuSection: Identifiable {
    let id = UUID()
    let name: String
    var items: [MenuItem]
}

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String?
    let price: Double?
    let currency: String
    let isAvailable: Bool
    var dietLabels: [String]    // e.g. ["l", "g", "v"]

    var formattedPrice: String? {
        guard let price else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price))
    }
}

// MARK: - Diet label display

extension String {
    /// Returns the localized description for a Finnish diet code (l, g, v, m, vl, k…).
    var dietLabelName: String {
        NSLocalizedString("diet.\(lowercased())", comment: "")
    }
}
