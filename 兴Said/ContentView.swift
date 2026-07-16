//
//  ContentView.swift
//  兴曰
//

import SwiftUI

struct ContentView: View {
    @AppStorage("selectedQuoteID") private var selectedQuoteID = "xing-0001"
    @AppStorage("backgroundIndex") private var backgroundIndex = 0
    @AppStorage("favoriteQuoteIDs") private var favoriteQuoteIDs = "xing-0001,xing-0014,xing-0173"
    @AppStorage("notificationMode") private var notificationMode = "random"
    @AppStorage("notificationCadence") private var notificationCadence = "daily"
    @AppStorage("notificationTime") private var notificationTime = "10:00"

    @State private var isShowingFavorites = false
    @State private var isShowingNotifications = false
    @State private var favoritesDetent: PresentationDetent = .medium
    @State private var instantQuoteID: String?

    private let quotes = XingQuoteStore.all
    private let backgrounds = XingBackground.palette
    private let defaultFavoriteIDs = Set(["xing-0001", "xing-0014", "xing-0173"])

    private var selectedQuote: XingQuote {
        quotes.first { $0.id == selectedQuoteID } ?? quotes[0]
    }

    private var favorites: Set<String> {
        let savedIDs = Set(favoriteQuoteIDs.split(separator: ",").map(String.init))
        let quoteIDs = Set(quotes.map(\.id))
        let validIDs = savedIDs.intersection(quoteIDs)

        if !savedIDs.isEmpty && validIDs.isEmpty {
            return defaultFavoriteIDs
        }

        return validIDs
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
                    onOpenNotifications: { isShowingNotifications = true }
                )
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.light)
        .sensoryFeedback(.selection, trigger: selectedQuoteID)
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
            .presentationDragIndicator(.visible)
            .presentationBackground {
                SheetGlassBackground(background: background)
            }
        }
        .sheet(isPresented: $isShowingNotifications) {
            NotificationsSheet(
                mode: $notificationMode,
                cadence: $notificationCadence,
                time: $notificationTime,
                onTest: {
                    let quote = quotes.randomElement()?.text ?? selectedQuote.text
                    return await NotificationService.sendTestNotification(quote: quote)
                }
            )
            .foregroundStyle(background.textColor)
            .tint(background.textColor)
            .preferredColorScheme(background.prefersLightText ? .dark : .light)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground {
                SheetGlassBackground(background: background)
            }
        }
    }

    private func nextBackground() {
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
}

#Preview {
    ContentView()
}
