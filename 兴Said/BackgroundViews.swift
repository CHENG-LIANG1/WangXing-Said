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
            if background.isSolid {
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
