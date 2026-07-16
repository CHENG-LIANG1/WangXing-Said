//
//  GestureGuideView.swift
//  兴曰
//

import SwiftUI

struct GestureGuideView: View {
    let tint: Color
    let onDismiss: () -> Void

    @State private var isAnimating = false
    @State private var isDismissing = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(alignment: .top, spacing: 38) {
                GestureHint(
                    systemName: "arrow.up.and.down",
                    title: "上下滑动",
                    subtitle: "切换语录",
                    tint: tint,
                    offset: isAnimating ? -5 : 5
                )

                GestureHint(
                    systemName: "hand.tap",
                    title: "双击屏幕",
                    subtitle: "切换背景",
                    tint: tint,
                    scale: isAnimating ? 1.06 : 0.94
                )
            }

            Spacer()

            Button(action: dismiss) {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 54, height: 54)
            }
            .buttonStyle(.plain)
            .adaptiveInteractiveGlass(in: Circle())
            .accessibilityLabel("开始浏览")
            .padding(.bottom, 38)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: dismiss)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .accessibilityAddTraits(.isModal)
    }

    private func dismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        HapticFeedback.success()
        withAnimation(.easeOut(duration: 0.24)) {
            onDismiss()
        }
    }
}

private struct GestureHint: View {
    let systemName: String
    let title: String
    let subtitle: String
    let tint: Color
    var offset: CGFloat = 0
    var scale: CGFloat = 1

    var body: some View {
        VStack(spacing: 13) {
            Image(systemName: systemName)
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 56, height: 56)
                .offset(y: offset)
                .scaleEffect(scale)

            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .opacity(0.68)
            }
            .foregroundStyle(tint)
            .frame(width: 104)
        }
        .frame(width: 112)
        .accessibilityElement(children: .combine)
    }
}
