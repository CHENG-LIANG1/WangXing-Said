//
//  ContentView.swift
//  兴曰
//

import SwiftUI

struct ContentView: View {
    @AppStorage("selectedQuoteID") private var selectedQuoteID = "xing-0001"
    @AppStorage("backgroundIndex") private var backgroundIndex = 0
    @AppStorage("favoriteQuoteIDs") private var favoriteQuoteIDs = ""
    @AppStorage("didMigrateDefaultFavorites") private var didMigrateDefaultFavorites = false
    @AppStorage("notificationMode") private var notificationMode = "random"
    @AppStorage("notificationRandomStartTime") private var notificationRandomStartTime = "09:00"
    @AppStorage("notificationRandomEndTime") private var notificationRandomEndTime = "21:00"
    @AppStorage("notificationTime") private var notificationTime = "10:00"
    @AppStorage("hasSeenGestureGuide") private var hasSeenGestureGuide = false

    @State private var isShowingFavorites = false
    @State private var isShowingNotifications = false
    @State private var favoritesDetent: PresentationDetent = .medium
    @State private var instantQuoteID: String?
    @State private var notificationRefreshTask: Task<Void, Never>?
    @State private var topSafeAreaInset: CGFloat = 0

    private let quotes = XingQuoteStore.all
    private let backgrounds = XingBackground.palette
    private let legacyDefaultFavoriteIDs = Set(["xing-0001", "xing-0014", "xing-0173"])

    private var selectedQuote: XingQuote {
        quotes.first { $0.id == selectedQuoteID } ?? quotes[0]
    }

    private var favorites: Set<String> {
        let savedIDs = Set(favoriteQuoteIDs.split(separator: ",").map(String.init))
        let quoteIDs = Set(quotes.map(\.id))
        return savedIDs.intersection(quoteIDs)
    }

    private var favoriteQuotes: [XingQuote] {
        let ids = favorites
        return quotes.filter { ids.contains($0.id) }
    }

    private var background: XingBackground {
        backgrounds[backgroundIndex % backgrounds.count]
    }

    var body: some View {
        ZStack {
            LiquidBackdrop(background: background)
                .animation(.easeInOut(duration: 0.32), value: backgroundIndex)

            QuotePager(
                quotes: quotes,
                selectedID: selectedQuoteID,
                instantSelectionID: instantQuoteID,
                textColor: background.textColor,
                onDoubleTap: nextBackground,
                onSelectionChange: { selectedQuoteID = $0 }
            )
            .opacity(hasSeenGestureGuide ? 1 : 0)
            .allowsHitTesting(hasSeenGestureGuide)

            if hasSeenGestureGuide {
                VStack(spacing: 0) {
                    if topSafeAreaInset > 24 {
                        ScreenshotBrandPill(tint: background.textColor)
                            .padding(.top, topSafeAreaInset + 8)
                    }

                    Spacer()
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .zIndex(2)

                VStack(spacing: 0) {
                    Spacer()

                    GlassToolbar(
                        isFavorite: favorites.contains(selectedQuote.id),
                        tint: background.textColor,
                        onOpenFavorites: {
                            favoritesDetent = .medium
                            isShowingFavorites = true
                        },
                        onToggleFavorite: toggleSelectedFavorite,
                        onOpenNotifications: {
                            isShowingNotifications = true
                            scheduleNotificationRefresh()
                        }
                    )
                    .padding(.bottom, 28)
                }
                .transition(.opacity)
            }

            if !hasSeenGestureGuide {
                GestureGuideView(
                    tint: background.textColor,
                    onDoubleTap: nextBackground
                ) {
                    hasSeenGestureGuide = true
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.safeAreaInsets.top
        } action: { newValue in
            topSafeAreaInset = newValue
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $isShowingFavorites) {
            FavoritesSheet(
                quotes: favoriteQuotes,
                selectedQuoteID: selectedQuoteID
            ) { quote in
                instantQuoteID = quote.id
                selectedQuoteID = quote.id
                isShowingFavorites = false
            }
            .foregroundStyle(background.textColor)
            .tint(background.textColor)
            .preferredColorScheme(background.prefersLightText ? .dark : .light)
            .presentationDetents([.medium, .large], selection: $favoritesDetent)
            .presentationCornerRadius(34)
            .presentationDragIndicator(.visible)
            .presentationBackground {
                SheetGlassBackground()
            }
        }
        .sheet(isPresented: $isShowingNotifications) {
            NotificationsSheet(
                mode: $notificationMode,
                randomStartTime: $notificationRandomStartTime,
                randomEndTime: $notificationRandomEndTime,
                scheduledTime: $notificationTime,
                onTest: {
                    let quote = quotes.randomElement()?.text ?? selectedQuote.text
                    return await NotificationService.sendTestNotification(quote: quote)
                }
            )
            .foregroundStyle(background.textColor)
            .tint(background.textColor)
            .preferredColorScheme(background.prefersLightText ? .dark : .light)
            .presentationDetents([.medium])
            .presentationCornerRadius(34)
            .presentationDragIndicator(.visible)
            .presentationBackground {
                SheetGlassBackground()
            }
        }
        .task {
            migrateDefaultFavoritesIfNeeded()
            await refreshNotifications(requestAuthorization: false)
        }
        .onChange(of: notificationMode) {
            scheduleNotificationRefresh()
        }
        .onChange(of: notificationRandomStartTime) {
            scheduleNotificationRefresh()
        }
        .onChange(of: notificationRandomEndTime) {
            scheduleNotificationRefresh()
        }
        .onChange(of: notificationTime) {
            scheduleNotificationRefresh()
        }
        .onChange(of: isShowingFavorites) { oldValue, newValue in
            if oldValue && !newValue {
                HapticFeedback.page()
            }
        }
        .onChange(of: isShowingNotifications) { oldValue, newValue in
            if oldValue && !newValue {
                HapticFeedback.page()
            }
        }
        .onChange(of: favoritesDetent) {
            if isShowingFavorites {
                HapticFeedback.page()
            }
        }
    }

    private func nextBackground() {
        HapticFeedback.backgroundChange()
        backgroundIndex = (backgroundIndex + 1) % backgrounds.count
    }

    private func toggleSelectedFavorite() {
        var ids = favorites
        if ids.contains(selectedQuote.id) {
            ids.remove(selectedQuote.id)
        } else {
            ids.insert(selectedQuote.id)
        }
        favoriteQuoteIDs = quotes.map(\.id).filter { ids.contains($0) }.joined(separator: ",")
    }

    private func migrateDefaultFavoritesIfNeeded() {
        guard !didMigrateDefaultFavorites else { return }

        let savedIDs = Set(favoriteQuoteIDs.split(separator: ",").map(String.init))
        if savedIDs == legacyDefaultFavoriteIDs {
            favoriteQuoteIDs = ""
        }
        didMigrateDefaultFavorites = true
    }

    private func scheduleNotificationRefresh() {
        notificationRefreshTask?.cancel()
        notificationRefreshTask = Task {
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            await refreshNotifications(requestAuthorization: true)
        }
    }

    private func refreshNotifications(requestAuthorization: Bool) async {
        await NotificationService.configure(
            mode: notificationMode,
            randomStartTime: notificationRandomStartTime,
            randomEndTime: notificationRandomEndTime,
            scheduledTime: notificationTime,
            quotes: quotes.map(\.text),
            requestAuthorization: requestAuthorization
        )
    }
}

#Preview {
    ContentView()
}
