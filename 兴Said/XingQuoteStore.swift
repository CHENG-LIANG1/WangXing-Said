//
//  XingQuoteStore.swift
//  兴曰
//

import Foundation

enum XingQuoteStore {
    static let all: [XingQuote] = {
        guard
            let url = Bundle.main.url(forResource: "XingQuotes", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let quotes = try? JSONDecoder().decode([XingQuote].self, from: data),
            !quotes.isEmpty
        else {
            return fallback
        }

        return quotes
    }()

    private static let fallback = [
        XingQuote(
            id: "xing-0001",
            text: "多数人为了逃避真正的思考，愿意做任何事情。",
            author: "王兴",
            platform: "饭否",
            tags: ["思维方式"],
            sources: [
                QuoteSource(
                    name: "本地备用",
                    url: "",
                    sourceNumber: 1,
                    date: nil
                )
            ]
        )
    ]
}
