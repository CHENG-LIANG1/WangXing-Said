//
//  NotificationService.swift
//  兴曰
//

import Foundation
import UserNotifications

enum TestNotificationResult {
    case scheduled
    case denied
    case failed
}

enum NotificationService {
    static func sendTestNotification(quote: String) async -> TestNotificationResult {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound])
                guard granted else { return .denied }
            } catch {
                return .failed
            }
        case .denied:
            return .denied
        case .authorized, .provisional, .ephemeral:
            break
        @unknown default:
            return .failed
        }

        let content = UNMutableNotificationContent()
        content.title = "兴曰"
        content.body = quote
        content.sound = .default
        content.threadIdentifier = "兴曰语录"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "兴曰试一试",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            return .scheduled
        } catch {
            return .failed
        }
    }
}

final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCenterDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
