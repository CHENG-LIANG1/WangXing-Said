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
    private static let scheduledIdentifierPrefix = "兴曰日常-v2-"
    private static let legacyIdentifierPrefix = "兴曰日常-"
    private static let schedulingDays = 28
    private static let randomPendingLimit = 56
    private static let randomPeriodLimit = 28
    private static let randomStartHour = 9
    private static let randomEndHour = 21

    static func configure(
        mode: String,
        cadence: String,
        scheduledTime: String,
        quotes: [XingQuote],
        requestAuthorization: Bool,
        forceReschedule: Bool
    ) async {
        let center = UNUserNotificationCenter.current()

        if mode == "off" {
            await removeScheduledNotifications(from: center)
            return
        }

        guard !Task.isCancelled, !quotes.isEmpty else { return }
        if !forceReschedule, await hasActiveSchedule(in: center) {
            return
        }

        await removeScheduledNotifications(from: center)
        guard await canScheduleNotifications(using: center, requestAuthorization: requestAuthorization) else {
            return
        }

        switch mode {
        case "random":
            await scheduleRandomNotifications(
                cadence: cadence,
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

    static func sendTestNotification(quote: XingQuote) async -> TestNotificationResult {
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
        content.subtitle = quote.attributionText
        content.body = quote.text
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
            .filter { $0.hasPrefix(legacyIdentifierPrefix) }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private static func hasActiveSchedule(in center: UNUserNotificationCenter) async -> Bool {
        await center.pendingNotificationRequests()
            .contains { $0.identifier.hasPrefix(scheduledIdentifierPrefix) }
    }

    private static func scheduleRandomNotifications(
        cadence: String,
        quotes: [XingQuote],
        center: UNUserNotificationCenter
    ) async {
        let calendar = Calendar.current
        let now = Date()
        let daysPerPeriod = cadenceDays(for: cadence)
        let firstPeriodStart = calendar.startOfDay(for: now)
        var scheduledCount = 0
        var periodIndex = 0

        while !Task.isCancelled,
              scheduledCount < randomPendingLimit,
              periodIndex < randomPeriodLimit {
            defer { periodIndex += 1 }

            guard
                let periodStart = calendar.date(
                    byAdding: .day,
                    value: periodIndex * daysPerPeriod,
                    to: firstPeriodStart
                ),
                let periodEnd = calendar.date(byAdding: .day, value: daysPerPeriod, to: periodStart)
            else {
                continue
            }

            let windows = deliveryWindows(
                from: periodStart,
                to: periodEnd,
                after: now.addingTimeInterval(5),
                calendar: calendar
            )
            guard !windows.isEmpty else { continue }

            let notificationCount = Int.random(in: 2...10)
            guard scheduledCount + notificationCount <= randomPendingLimit else { break }

            let dates = randomDates(count: notificationCount, within: windows)
            guard dates.count == notificationCount else { continue }
            for (slot, date) in dates.enumerated() {
                await addNotification(
                    at: date,
                    quote: quotes.randomElement() ?? quotes[0],
                    identifier: "\(scheduledIdentifierPrefix)random-\(periodIndex)-\(slot)",
                    center: center
                )
            }

            scheduledCount += notificationCount
        }
    }

    private static func scheduleDailyNotifications(
        at time: String,
        quotes: [XingQuote],
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
        quote: XingQuote,
        identifier: String,
        center: UNUserNotificationCenter
    ) async {
        guard !Task.isCancelled else { return }

        let content = UNMutableNotificationContent()
        content.title = "兴曰"
        content.subtitle = quote.attributionText
        content.body = quote.text
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

    private static func cadenceDays(for cadence: String) -> Int {
        switch cadence {
        case "2days": 2
        case "weekly": 7
        default: 1
        }
    }

    private static func deliveryWindows(
        from periodStart: Date,
        to periodEnd: Date,
        after earliestDate: Date,
        calendar: Calendar
    ) -> [(start: Date, end: Date)] {
        var windows: [(start: Date, end: Date)] = []
        var day = periodStart

        while day < periodEnd {
            guard
                let start = calendar.date(bySettingHour: randomStartHour, minute: 0, second: 0, of: day),
                let end = calendar.date(bySettingHour: randomEndHour, minute: 0, second: 0, of: day)
            else {
                day = calendar.date(byAdding: .day, value: 1, to: day) ?? periodEnd
                continue
            }

            let clippedStart = max(start, earliestDate)
            if clippedStart < end {
                windows.append((clippedStart, end))
            }

            day = calendar.date(byAdding: .day, value: 1, to: day) ?? periodEnd
        }

        return windows
    }

    private static func randomDates(
        count: Int,
        within windows: [(start: Date, end: Date)]
    ) -> [Date] {
        let durations = windows.map { max(0, Int($0.end.timeIntervalSince($0.start))) }
        let totalDuration = durations.reduce(0, +)
        let minimumAverageSpacing = 30 * 60
        guard totalDuration >= count * minimumAverageSpacing else { return [] }

        let offsets = (0..<count).map { index in
            let lowerBound = totalDuration * index / count
            let upperBound = totalDuration * (index + 1) / count
            return Int.random(in: lowerBound..<upperBound)
        }

        return offsets.compactMap { offset in
            var remaining = offset
            for (index, duration) in durations.enumerated() {
                if remaining < duration {
                    return windows[index].start.addingTimeInterval(TimeInterval(remaining))
                }
                remaining -= duration
            }
            return nil
        }
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
