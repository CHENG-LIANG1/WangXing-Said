//
//  QuotePager.swift
//  兴曰
//

import SwiftUI

struct QuotePager: View {
    let quotes: [XingQuote]
    let selectedID: String
    let instantSelectionID: String?
    let textColor: Color
    let onDoubleTap: () -> Void
    let onSelectionChange: (String) -> Void

    @State private var scrollID: String?

    init(
        quotes: [XingQuote],
        selectedID: String,
        instantSelectionID: String? = nil,
        textColor: Color,
        onDoubleTap: @escaping () -> Void,
        onSelectionChange: @escaping (String) -> Void
    ) {
        self.quotes = quotes
        self.selectedID = selectedID
        self.instantSelectionID = instantSelectionID
        self.textColor = textColor
        self.onDoubleTap = onDoubleTap
        self.onSelectionChange = onSelectionChange
        _scrollID = State(initialValue: selectedID)
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(quotes) { quote in
                    QuotePage(
                        quote: quote,
                        textColor: textColor,
                        onDoubleTap: onDoubleTap
                    )
                    .containerRelativeFrame(.vertical)
                    .id(quote.id)
                    .scrollTransition(.interactive, axis: .vertical) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.52)
                            .scaleEffect(phase.isIdentity ? 1 : 0.975)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .adaptiveQuotePaging()
        .scrollPosition(id: $scrollID)
        .onScrollPhaseChange { _, newPhase in
            guard newPhase == .idle, let scrollID, scrollID != selectedID else { return }
            HapticFeedback.page()
            onSelectionChange(scrollID)
        }
        .onChange(of: selectedID) { _, newID in
            guard scrollID != newID else { return }

            if newID == instantSelectionID {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    scrollID = newID
                }
            } else {
                withAnimation(.smooth(duration: 0.38)) {
                    scrollID = newID
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct QuotePage: View {
    let quote: XingQuote
    let textColor: Color
    let onDoubleTap: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Text(quote.text)
                .font(.system(size: 23, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .minimumScaleFactor(0.68)
                .foregroundStyle(textColor)

            Text(quote.attributionText)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(textColor.opacity(0.78))
        }
        .frame(maxWidth: 340)
        .padding(.horizontal, 28)
        .padding(.bottom, 92)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: onDoubleTap)
        .accessibilityHint("上下滑动切换语录，双击切换背景")
    }
}
