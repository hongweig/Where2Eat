import Foundation
import CoreLocation

class LounaatService {
    private let apiKey: String
    private let base = "https://www.lounaat.info/api"
    private let session = URLSession.shared

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // Returns nearby restaurants with today's lunch menu items.
    func nearby(lat: Double, lng: Double) async throws -> [LounaatRestaurant] {
        let url = try makeURL("/near", params: ["lat": "\(lat)", "lng": "\(lng)"])
        return try await fetch([LounaatRestaurant].self, from: url)
    }

    // Returns a single restaurant with its full weekly menu.
    func restaurant(id: String) async throws -> LounaatRestaurant {
        let url = try makeURL("/restaurant", params: ["id": id])
        return try await fetch(LounaatRestaurant.self, from: url)
    }

    private func makeURL(_ path: String, params: [String: String]) throws -> URL {
        var components = URLComponents(string: base + path)!
        var items = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        items.append(URLQueryItem(name: "apikey", value: apiKey))
        components.queryItems = items
        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }

    private func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Conversion to app models

extension LounaatRestaurant {
    func toRestaurant() -> Restaurant {
        let lat = Double(lat) ?? 0
        let lng = Double(lng) ?? 0
        return Restaurant(
            id: id,
            name: name,
            address: address,
            coordinate: .init(latitude: lat, longitude: lng),
            category: NSLocalizedString("category.restaurant", comment: ""),
            phone: nil,
            url: url.flatMap(URL.init),
            distance: distance.flatMap(Double.init).map { $0 * 1000 }, // km → m
            lunchTimeText: lunchTime.map { "\($0.start.hhmm)–\($0.end.hhmm)" }
        )
    }

    func toLunchMenu(for weekday: Weekday?) -> DailyMenu {
        // /api/near items have no `day` field → they are all for today.
        // /api/restaurant items have a `day` bitmask → filter by weekday.
        let filtered: [LounaatMenuItem]
        if let weekday {
            filtered = menuItems.filter { item in
                guard let dayStr = item.day, let bits = Int(dayStr) else { return true }
                return bits & weekday.rawValue != 0
            }
        } else {
            filtered = menuItems
        }

        let items = filtered.map { m in
            MenuItem(
                name: m.item,
                description: m.info?.isEmpty == false ? m.info : nil,
                price: m.price.flatMap { parsePrice($0) },
                currency: "EUR",
                isAvailable: true,
                dietLabels: m.dietinfo ?? []
            )
        }

        let section = MenuSection(name: NSLocalizedString("menu.section.lunch", comment: ""), items: items)
        return DailyMenu(
            restaurantId: id,
            date: Date(),
            mealPeriod: .lunch,
            sections: items.isEmpty ? [] : [section]
        )
    }

    private func parsePrice(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: ".").filter { $0.isNumber || $0 == "." })
    }
}

private extension String {
    // "11:00:00" → "11:00"
    var hhmm: String { String(prefix(5)) }
}
