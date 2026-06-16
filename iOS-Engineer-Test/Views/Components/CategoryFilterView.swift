import SwiftUI

struct CategoryFilterView: View {
    let categories: [String]
    let selected: String
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: selected.isEmpty) {
                    onSelect("")
                }

                ForEach(categories, id: \.self) { category in
                    FilterChip(
                        label: category,
                        isSelected: selected == category
                    ) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Category Filter") {
    @Previewable @State var selected = "Software Development"
    CategoryFilterView(
        categories: ["Software Development", "Design", "Marketing", "DevOps / Sysadmin"],
        selected: selected
    ) { cat in
        selected = cat
    }
}
