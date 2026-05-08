import Foundation

// Sample menu data used when no real menu API is available.
// Replace RestaurantService.fetchMenu() to use live data from your chosen API.
struct MockMenuProvider {

    static func menu(for restaurant: Restaurant, period: MealPeriod) -> DailyMenu {
        DailyMenu(
            restaurantId: restaurant.id,
            date: Date(),
            mealPeriod: period,
            sections: sections(for: period)
        )
    }

    private static func sections(for period: MealPeriod) -> [MenuSection] {
        switch period {
        case .breakfast:
            return [
                MenuSection(name: NSLocalizedString("menu.section.classic", comment: ""), items: [
                    item("menu.item.oatmeal",       "menu.item.oatmeal.desc",       price: 6.50),
                    item("menu.item.egg_toast",     "menu.item.egg_toast.desc",     price: 8.00),
                    item("menu.item.fruit_yogurt",  "menu.item.fruit_yogurt.desc",  price: 5.50),
                ]),
                MenuSection(name: NSLocalizedString("menu.section.drinks", comment: ""), items: [
                    item("menu.item.coffee",        nil,    price: 4.00),
                    item("menu.item.oj",            nil,    price: 3.50),
                    item("menu.item.hot_tea",       nil,    price: 3.00),
                ]),
            ]

        case .lunch:
            return [
                MenuSection(name: NSLocalizedString("menu.section.mains", comment: ""), items: [
                    item("menu.item.caesar_salad",  "menu.item.caesar_salad.desc",  price: 12.00),
                    item("menu.item.pasta",         "menu.item.pasta.desc",         price: 14.50),
                    item("menu.item.burger",        "menu.item.burger.desc",        price: 15.00),
                    item("menu.item.fried_rice",    "menu.item.fried_rice.desc",    price: 13.00),
                ]),
                MenuSection(name: NSLocalizedString("menu.section.sides", comment: ""), items: [
                    item("menu.item.soup",          "menu.item.soup.desc",          price: 6.00),
                    item("menu.item.side_salad",    nil,    price: 5.00),
                ]),
                MenuSection(name: NSLocalizedString("menu.section.drinks", comment: ""), items: [
                    item("menu.item.iced_tea",      nil,    price: 3.50),
                    item("menu.item.soda",          nil,    price: 2.50),
                ]),
            ]

        case .dinner:
            return [
                MenuSection(name: NSLocalizedString("menu.section.starters", comment: ""), items: [
                    item("menu.item.bruschetta",    "menu.item.bruschetta.desc",    price: 9.00),
                    item("menu.item.edamame",       nil,    price: 5.50),
                ]),
                MenuSection(name: NSLocalizedString("menu.section.mains", comment: ""), items: [
                    item("menu.item.steak",         "menu.item.steak.desc",         price: 28.00),
                    item("menu.item.salmon",        "menu.item.salmon.desc",        price: 24.00),
                    item("menu.item.ramen",         "menu.item.ramen.desc",         price: 16.00),
                    item("menu.item.pizza",         "menu.item.pizza.desc",         price: 18.00),
                ]),
                MenuSection(name: NSLocalizedString("menu.section.desserts", comment: ""), items: [
                    item("menu.item.tiramisu",      "menu.item.tiramisu.desc",      price: 8.00),
                    item("menu.item.ice_cream",     nil,    price: 6.00),
                ]),
            ]
        }
    }

    private static var localCurrency: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private static func item(_ nameKey: String,
                              _ descKey: String?,
                              price: Double,
                              currency: String? = nil) -> MenuItem {
        MenuItem(
            name: NSLocalizedString(nameKey, comment: ""),
            description: descKey.map { NSLocalizedString($0, comment: "") },
            price: price,
            currency: currency ?? localCurrency,
            isAvailable: true
        )
    }
}
