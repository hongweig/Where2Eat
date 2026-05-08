import SwiftUI

struct MenuView: View {
    let menu: DailyMenu?
    let isLoading: Bool

    var body: some View {
        Group {
            if isLoading {
                HStack { Spacer(); ProgressView("loading_menu"); Spacer() }
                    .padding(.vertical, 40)
            } else if let menu, !menu.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(menu.sections) { section in
                        MenuSectionView(section: section)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.largeTitle).foregroundColor(.secondary)
                    Text("menu_unavailable")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40)
            }
        }
    }
}

struct MenuSectionView: View {
    let section: MenuSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.name)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundColor(.secondary).textCase(.uppercase)

            VStack(spacing: 1) {
                ForEach(section.items) { item in
                    MenuItemRow(item: item)
                    if item.id != section.items.last?.id {
                        Divider().padding(.leading, 14)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(item.name)
                    .font(.body)
                    .foregroundColor(item.isAvailable ? .primary : .secondary)
                Spacer()
                if let price = item.formattedPrice {
                    Text(price)
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(item.isAvailable ? .accentColor : .secondary)
                }
            }

            if let desc = item.description {
                Text(desc)
                    .font(.caption).foregroundColor(.secondary)
                    .lineLimit(2)
            }

            if !item.dietLabels.isEmpty {
                HStack(spacing: 4) {
                    ForEach(item.dietLabels, id: \.self) { label in
                        DietBadge(label: label)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .opacity(item.isAvailable ? 1 : 0.5)
    }
}

struct DietBadge: View {
    let label: String

    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .help(label.dietLabelName)
    }

    private var color: Color {
        switch label.lowercased() {
        case "v":  return .green
        case "vl": return .mint
        case "l":  return .blue
        case "g":  return .orange
        case "m":  return .purple
        default:   return .gray
        }
    }
}
