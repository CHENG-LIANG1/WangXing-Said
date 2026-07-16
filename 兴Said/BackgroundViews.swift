//
//  BackgroundViews.swift
//  兴曰
//

import SwiftUI

struct SheetGlassBackground: View {
    let background: XingBackground

    var body: some View {
        LinearGradient(
            stops: background.gradientStops,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .glassEffect(
            .regular.tint(background.color.opacity(0.26)),
            in: Rectangle()
        )
        .ignoresSafeArea()
    }
}

struct LiquidBackdrop: View {
    let background: XingBackground

    var body: some View {
        ZStack {
            LinearGradient(
                stops: background.gradientStops,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    .white.opacity(0.16),
                    .clear,
                    .black.opacity(background.prefersLightText ? 0.22 : 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}
