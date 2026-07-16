//
//  _SaidApp.swift
//  兴Said
//
//  Created by Ray on 2026/7/16.
//

import Foundation
import SwiftUI
import UserNotifications

@main
struct _SaidApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationCenterDelegate.shared
        selectRandomLaunchQuote()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func selectRandomLaunchQuote() {
        let quotes = XingQuoteStore.all
        guard !quotes.isEmpty else { return }

        let defaults = UserDefaults.standard
        let previousID = defaults.string(forKey: "selectedQuoteID")
        let candidates = quotes.count > 1 ? quotes.filter { $0.id != previousID } : quotes

        if let quote = candidates.randomElement() {
            defaults.set(quote.id, forKey: "selectedQuoteID")
        }
    }
}
