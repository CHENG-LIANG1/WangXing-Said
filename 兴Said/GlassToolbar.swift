//
//  GlassToolbar.swift
//  兴曰
//

import SwiftUI

struct GlassToolbar: View {
    let isFavorite: Bool
    let tint: Color
    let onOpenFavorites: () -> Void
    let onToggleFavorite: () -> Void
    let onOpenNotifications: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ToolbarButton(
                systemName: "heart.text.square",
                label: "收藏列表",
                tint: tint,
                action: onOpenFavorites
            )

            ToolbarButton(
                systemName: isFavorite ? "heart.fill" : "heart",
                label: isFavorite ? "取消收藏" : "收藏",
                tint: tint,
                isSelected: isFavorite,
                action: onToggleFavorite
            )

            ToolbarButton(
                systemName: "bell",
                label: "通知",
                tint: tint,
                action: onOpenNotifications
            )
        }
        .padding(5)
        .glassEffect(.regular.interactive(), in: Capsule())
    }
}

private struct ToolbarButton: View {
    let systemName: String
    let label: String
    let tint: Color
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .symbolEffect(.bounce, value: isSelected)
                .frame(width: 56, height: 48)
                .foregroundStyle(tint)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
