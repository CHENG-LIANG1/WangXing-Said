//
//  FavoritesSheet.swift
//  兴曰
//

import SwiftUI

struct FavoritesSheet: View {
    let quotes: [XingQuote]
    let selectedQuoteID: String
    let onSelect: (XingQuote) -> Void

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(
                title: "收藏",
                subtitle: quotes.isEmpty ? "还没有收藏语录" : "已收藏 \(quotes.count) 条语录"
            )

            Divider()
                .opacity(0.45)

            if quotes.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "heart")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text("在首页点击心形按钮收藏语录")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(quotes.enumerated()), id: \.element.id) { index, quote in
                            Button {
                                HapticFeedback.selection()
                                onSelect(quote)
                            } label: {
                                HStack(alignment: .center, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 7) {
                                        Text(quote.text)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .lineLimit(4)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.primary)

                                        Text(quote.attributionText)
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer(minLength: 8)

                                    Image(systemName: quote.id == selectedQuoteID ? "checkmark.circle.fill" : "chevron.right")
                                        .font(.system(size: quote.id == selectedQuoteID ? 19 : 13, weight: .bold))
                                        .foregroundStyle(quote.id == selectedQuoteID ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary))
                                }
                                .padding(.vertical, 17)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if index < quotes.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
