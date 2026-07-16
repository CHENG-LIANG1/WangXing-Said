//
//  HapticFeedback.swift
//  兴曰
//

import UIKit

@MainActor
enum HapticFeedback {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    static func tap() {
        lightImpact.impactOccurred(intensity: 0.72)
        lightImpact.prepare()
    }

    static func page() {
        softImpact.impactOccurred(intensity: 0.9)
        softImpact.prepare()
    }

    static func backgroundChange() {
        mediumImpact.impactOccurred(intensity: 0.78)
        mediumImpact.prepare()
    }

    static func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    static func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    static func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }
}
