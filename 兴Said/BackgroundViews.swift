//
//  BackgroundViews.swift
//  兴曰
//

import SwiftUI

struct SheetGlassBackground: View {
    var body: some View {
        Color.white
            .opacity(0.001)
            .adaptiveSheetGlass(in: sheetShape)
        .ignoresSafeArea()
    }

    private var sheetShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 34,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 34,
            style: .continuous
        )
    }
}

struct LiquidBackdrop: View {
    let background: XingBackground

    var body: some View {
        Group {
            if background.isGlass {
                LiquidGlassGradientBackdrop(background: background)
            } else if background.isSolid {
                ZStack {
                    background.topColor

                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.11), location: 0),
                            .init(color: .clear, location: 0.48),
                            .init(color: .black.opacity(0.09), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            } else {
                BackgroundGradient(background: background)
            }
        }
        .ignoresSafeArea()
    }
}

private struct LiquidGlassGradientBackdrop: View {
    let background: XingBackground

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    background.topColor.opacity(0.94),
                    background.middleColor.opacity(0.78),
                    background.bottomColor.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { proxy in
                let size = proxy.size

                Circle()
                    .fill(Color(red: 0.36, green: 0.62, blue: 1).opacity(0.42))
                    .frame(width: size.width * 0.95, height: size.width * 0.95)
                    .blur(radius: 76)
                    .offset(x: -size.width * 0.34, y: -size.height * 0.08)

                Circle()
                    .fill(Color(red: 0.78, green: 0.55, blue: 1).opacity(0.34))
                    .frame(width: size.width * 0.82, height: size.width * 0.82)
                    .blur(radius: 82)
                    .offset(x: size.width * 0.50, y: size.height * 0.24)

                Circle()
                    .fill(Color(red: 1, green: 0.61, blue: 0.72).opacity(0.30))
                    .frame(width: size.width * 0.76, height: size.width * 0.76)
                    .blur(radius: 88)
                    .offset(x: -size.width * 0.16, y: size.height * 0.72)
            }

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.70)

            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.70), location: 0),
                    .init(color: .white.opacity(0.12), location: 0.30),
                    .init(color: .clear, location: 0.56),
                    .init(color: .white.opacity(0.28), location: 1)
                ],
                startPoint: UnitPoint(x: 0.06, y: 0),
                endPoint: UnitPoint(x: 0.88, y: 1)
            )

            RadialGradient(
                colors: [.white.opacity(0.52), .clear],
                center: UnitPoint(x: 0.72, y: 0.12),
                startRadius: 0,
                endRadius: 240
            )
            .blendMode(.screen)
        }
    }
}

private struct BackgroundGradient: View {
    let background: XingBackground

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: background.topColor, location: 0),
                .init(color: background.middleColor, location: 0.52),
                .init(color: background.bottomColor, location: 1)
            ],
            startPoint: UnitPoint(x: 0.38, y: 0),
            endPoint: UnitPoint(x: 0.62, y: 1)
        )
    }
}
