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
    private static let scheduledIdentifierPrefix = "兴曰日常-"
    private static let schedulingDays = 28

    static func configure(
        mode: String,
        randomStartTime: String,
        randomEndTime: String,
        scheduledTime: String,
        quotes: [String],
        requestAuthorization: Bool
    ) async {
        let center = UNUserNotificationCenter.current()
        await removeScheduledNotifications(from: center)

        guard !Task.isCancelled, mode != "off", !quotes.isEmpty else { return }
        guard await canScheduleNotifications(using: center, requestAuthorization: requestAuthorization) else {
            return
        }

        switch mode {
        case "random":
            await scheduleRandomNotifications(
                from: randomStartTime,
                to: randomEndTime,
                quotes: quotes,
                center: center
            )
        case "scheduled":
            await scheduleDailyNotifications(
                at: scheduledTime,
                quotes: quotes,
                center: center
            )
        default:
            break
        }
    }

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

    private static func canScheduleNotifications(
        using center: UNUserNotificationCenter,
        requestAuthorization: Bool
    ) async -> Bool {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined where requestAuthorization:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) == true
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    private static func removeScheduledNotifications(from center: UNUserNotificationCenter) async {
        let identifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(scheduledIdentifierPrefix) }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private static func scheduleRandomNotifications(
        from startTime: String,
        to endTime: String,
        quotes: [String],
        center: UNUserNotificationCenter
    ) async {
        guard let start = timeComponents(from: startTime), let end = timeComponents(from: endTime) else {
            return
        }

        let calendar = Calendar.current
        let now = Date()
        var scheduledDayCount = 0
        var dayOffset = 0

        while !Task.isCancelled, scheduledDayCount < schedulingDays, dayOffset < schedulingDays + 2 {
            defer { dayOffset += 1 }

            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now)),
                let windowStart = calendar.date(bySettingHour: start.hour, minute: start.minute, second: 0, of: day),
                var windowEnd = calendar.date(bySettingHour: end.hour, minute: end.minute, second: 0, of: day)
            else {
                continue
            }

            if windowEnd <= windowStart {
                guard let nextDayEnd = calendar.date(byAdding: .day, value: 1, to: windowEnd) else { continue }
                windowEnd = nextDayEnd
            }

            let earliest = max(windowStart, now.addingTimeInterval(5))
            guard earliest < windowEnd else { continue }

            let dates = twoRandomDates(from: earliest, to: windowEnd)
            for (slot, date) in dates.enumerated() {
                await addNotification(
                    at: date,
                    quote: quotes.randomElement() ?? quotes[0],
                    identifier: "\(scheduledIdentifierPrefix)\(dayOffset)-\(slot)",
                    center: center
                )
            }

            scheduledDayCount += 1
        }
    }

    private static func scheduleDailyNotifications(
        at time: String,
        quotes: [String],
        center: UNUserNotificationCenter
    ) async {
        guard let selectedTime = timeComponents(from: time) else { return }

        let calendar = Calendar.current
        let now = Date()

        var scheduledDayCount = 0
        var dayOffset = 0

        while !Task.isCancelled, scheduledDayCount < schedulingDays, dayOffset <= schedulingDays {
            defer { dayOffset += 1 }

            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now)),
                let date = calendar.date(
                    bySettingHour: selectedTime.hour,
                    minute: selectedTime.minute,
                    second: 0,
                    of: day
                )
            else {
                continue
            }

            guard date > now else { continue }

            await addNotification(
                at: date,
                quote: quotes.randomElement() ?? quotes[0],
                identifier: "\(scheduledIdentifierPrefix)fixed-\(scheduledDayCount)",
                center: center
            )
            scheduledDayCount += 1
        }
    }

    private static func addNotification(
        at date: Date,
        quote: String,
        identifier: String,
        center: UNUserNotificationCenter
    ) async {
        guard !Task.isCancelled else { return }

        let content = UNMutableNotificationContent()
        content.title = "兴曰"
        content.body = quote
        content.sound = .default
        content.threadIdentifier = "兴曰语录"

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    private static func twoRandomDates(from start: Date, to end: Date) -> [Date] {
        let duration = max(2, Int(end.timeIntervalSince(start)))
        let firstOffset = Int.random(in: 0..<(duration / 2))
        let secondOffset = Int.random(in: (duration / 2)..<duration)

        return [
            start.addingTimeInterval(TimeInterval(firstOffset)),
            start.addingTimeInterval(TimeInterval(secondOffset))
        ]
    }

    private static func timeComponents(from value: String) -> (hour: Int, minute: Int)? {
        let parts = value.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2, (0...23).contains(parts[0]), (0...59).contains(parts[1]) else {
            return nil
        }
        return (parts[0], parts[1])
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
