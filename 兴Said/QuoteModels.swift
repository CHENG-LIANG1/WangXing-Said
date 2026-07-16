//
//  QuoteModels.swift
//  兴曰
//

import Foundation

struct XingQuote: Codable, Identifiable, Equatable {
    let id: String
    let text: String
    let author: String
    let platform: String
    let tags: [String]
    let sources: [QuoteSource]
}

struct QuoteSource: Codable, Equatable {
    let name: String
    let url: String
    let sourceNumber: Int
}
