//
//  XingBackground.swift
//  兴曰
//

import SwiftUI

struct XingBackground {
    let topColor: Color
    let middleColor: Color
    let bottomColor: Color
    let textColor: Color
    let prefersLightText: Bool
    let isSolid: Bool
    let isGlass: Bool

    init(
        topColor: Color,
        middleColor: Color,
        bottomColor: Color,
        textColor: Color,
        prefersLightText: Bool,
        isSolid: Bool = false,
        isGlass: Bool = false
    ) {
        self.topColor = topColor
        self.middleColor = middleColor
        self.bottomColor = bottomColor
        self.textColor = textColor
        self.prefersLightText = prefersLightText
        self.isSolid = isSolid
        self.isGlass = isGlass
    }

    static func solid(_ color: Color, textColor: Color, prefersLightText: Bool) -> XingBackground {
        XingBackground(
            topColor: color,
            middleColor: color,
            bottomColor: color,
            textColor: textColor,
            prefersLightText: prefersLightText,
            isSolid: true
        )
    }

    static let liquidGlass = XingBackground(
        topColor: Color(hex: 0xF8FAFF),
        middleColor: Color(hex: 0xE8EEFF),
        bottomColor: Color(hex: 0xFDF6FC),
        textColor: Color(hex: 0x11131A),
        prefersLightText: false,
        isGlass: true
    )

    static let palette = [
        // Soft, low-contrast gradients inspired by established editorial palettes.
        XingBackground(topColor: Color(hex: 0xFF9A9E), middleColor: Color(hex: 0xFCAFB1), bottomColor: Color(hex: 0xFAD0C4), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0xFFECD2), middleColor: Color(hex: 0xFFD2B9), bottomColor: Color(hex: 0xFCB69F), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0xF6D365), middleColor: Color(hex: 0xF7BA75), bottomColor: Color(hex: 0xFDA085), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0xFBC2EB), middleColor: Color(hex: 0xD9C2ED), bottomColor: Color(hex: 0xA6C1EE), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0xA1C4FD), middleColor: Color(hex: 0xB2D7FC), bottomColor: Color(hex: 0xC2E9FB), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0xD4FC79), middleColor: Color(hex: 0xB5F18C), bottomColor: Color(hex: 0x96E6A1), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0x84FAB0), middleColor: Color(hex: 0x89E7C7), bottomColor: Color(hex: 0x8FD3F4), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0xA8EDEA), middleColor: Color(hex: 0xD1E2E6), bottomColor: Color(hex: 0xFED6E3), textColor: .black, prefersLightText: false),
        XingBackground(topColor: Color(hex: 0xCFD9DF), middleColor: Color(hex: 0xD9E2E7), bottomColor: Color(hex: 0xE2EBF0), textColor: .black, prefersLightText: false),

        XingBackground(topColor: Color(hex: 0x0B1026), middleColor: Color(hex: 0x17254A), bottomColor: Color(hex: 0x243B6B), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x21152E), middleColor: Color(hex: 0x3E2347), bottomColor: Color(hex: 0x5A315D), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x0B281F), middleColor: Color(hex: 0x153F32), bottomColor: Color(hex: 0x1F5A46), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x2A0F1B), middleColor: Color(hex: 0x4A192A), bottomColor: Color(hex: 0x6D263D), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x092C32), middleColor: Color(hex: 0x10464E), bottomColor: Color(hex: 0x17606A), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x1B1638), middleColor: Color(hex: 0x272751), bottomColor: Color(hex: 0x343B78), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x18181E), middleColor: Color(hex: 0x38252F), bottomColor: Color(hex: 0x583342), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x071D33), middleColor: Color(hex: 0x0F354B), bottomColor: Color(hex: 0x164E63), textColor: .white, prefersLightText: true),
        XingBackground(topColor: Color(hex: 0x202619), middleColor: Color(hex: 0x353E24), bottomColor: Color(hex: 0x4B5630), textColor: .white, prefersLightText: true),

        .solid(.black, textColor: .white, prefersLightText: true),
        .solid(.white, textColor: .black, prefersLightText: false),
        .solid(Color(red: 1.00, green: 0.48, blue: 0.00), textColor: .black, prefersLightText: false),
        .solid(Color(red: 0.20, green: 0.78, blue: 0.35), textColor: .black, prefersLightText: false),
        .solid(Color(red: 1.00, green: 0.84, blue: 0.04), textColor: .black, prefersLightText: false),
        .solid(Color(red: 0.00, green: 0.48, blue: 1.00), textColor: .white, prefersLightText: true),
        .solid(Color(red: 1.00, green: 0.23, blue: 0.19), textColor: .white, prefersLightText: true),
        .solid(Color(red: 1.00, green: 0.18, blue: 0.33), textColor: .white, prefersLightText: true),
        .solid(Color(red: 0.69, green: 0.32, blue: 0.87), textColor: .white, prefersLightText: true),
        .solid(Color(red: 0.20, green: 0.68, blue: 0.90), textColor: .black, prefersLightText: false),

        liquidGlass
    ]
}

private extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
