//
//  ScreenshotBrandPill.swift
//  兴曰
//

import SwiftUI

struct ScreenshotBrandPill: View {
    let tint: Color

    var body: some View {
        Text("兴曰 App")
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(tint)
            .frame(width: 86, height: 32)
            .adaptiveSheetGlass(in: Capsule())
            .accessibilityLabel("兴曰 App")
            .allowsHitTesting(false)
    }
}
