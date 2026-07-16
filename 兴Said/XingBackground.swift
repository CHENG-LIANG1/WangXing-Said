//
//  XingBackground.swift
//  兴曰
//

import SwiftUI

struct XingBackground {
    let color: Color
    let collisionColor: Color
    let textColor: Color
    let prefersLightText: Bool

    var gradientStops: [Gradient.Stop] {
        [
            Gradient.Stop(color: color, location: 0),
            Gradient.Stop(color: color, location: 0.38),
            Gradient.Stop(color: collisionColor, location: 0.72),
            Gradient.Stop(color: collisionColor, location: 1)
        ]
    }

    static let palette = [
        XingBackground(color: Color(red: 1.00, green: 0.42, blue: 0.22), collisionColor: Color(red: 1.00, green: 0.28, blue: 0.62), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.98, green: 0.84, blue: 0.18), collisionColor: Color(red: 0.62, green: 0.94, blue: 0.16), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.28, green: 0.86, blue: 0.62), collisionColor: Color(red: 0.10, green: 0.72, blue: 0.95), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.68, green: 0.58, blue: 0.98), collisionColor: Color(red: 1.00, green: 0.45, blue: 0.38), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.00, green: 0.80, blue: 0.68), collisionColor: Color(red: 1.00, green: 0.88, blue: 0.18), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.20, green: 0.65, blue: 1.00), collisionColor: Color(red: 1.00, green: 0.55, blue: 0.12), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 1.00, green: 0.30, blue: 0.60), collisionColor: Color(red: 1.00, green: 0.56, blue: 0.16), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.65, green: 0.85, blue: 1.00), collisionColor: Color(red: 0.98, green: 0.72, blue: 0.10), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.45, green: 0.90, blue: 0.45), collisionColor: Color(red: 1.00, green: 0.48, blue: 0.70), textColor: .black, prefersLightText: false),
        XingBackground(color: Color(red: 0.08, green: 0.09, blue: 0.12), collisionColor: Color(red: 0.10, green: 0.25, blue: 0.65), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.25, green: 0.08, blue: 0.58), collisionColor: Color(red: 0.65, green: 0.05, blue: 0.38), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.02, green: 0.12, blue: 0.28), collisionColor: Color(red: 0.00, green: 0.35, blue: 0.38), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.62, green: 0.02, blue: 0.16), collisionColor: Color(red: 0.30, green: 0.05, blue: 0.45), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.02, green: 0.22, blue: 0.58), collisionColor: Color(red: 0.68, green: 0.18, blue: 0.02), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.02, green: 0.25, blue: 0.18), collisionColor: Color(red: 0.15, green: 0.10, blue: 0.40), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.00, green: 0.30, blue: 0.42), collisionColor: Color(red: 0.52, green: 0.00, blue: 0.32), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.38, green: 0.05, blue: 0.28), collisionColor: Color(red: 0.02, green: 0.28, blue: 0.55), textColor: .white, prefersLightText: true),
        XingBackground(color: Color(red: 0.25, green: 0.28, blue: 0.02), collisionColor: Color(red: 0.55, green: 0.08, blue: 0.08), textColor: .white, prefersLightText: true)
    ]
}
