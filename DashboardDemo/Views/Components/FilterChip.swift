//
//  FilterChip.swift
//  DashboardDemo
//
//  Lightweight, reusable filter chip component with modern glassmorphism.
//

import SwiftUI

/// Stateless chip pill used for filtering authors and tags.
struct FilterChip: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.25) : Color.primary.opacity(0.08))
                        .foregroundStyle(isSelected ? Color.white : Color.secondary)
                        .clipShape(Capsule())
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(
                Capsule()
                    .fill(isSelected ? AnyShapeStyle(Color.indigo) : AnyShapeStyle(.ultraThinMaterial))
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.primary.opacity(0.08),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color.indigo.opacity(0.35) : Color.black.opacity(0.03),
                radius: isSelected ? 6 : 2,
                x: 0,
                y: isSelected ? 2 : 1
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview("FilterChip - States") {
    HStack(spacing: 8) {
        FilterChip(title: "All Authors", isSelected: true) {}
        FilterChip(title: "Leanne Graham", subtitle: "LG", isSelected: false) {}
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
