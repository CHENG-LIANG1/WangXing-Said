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

    var attributionText: String {
        var components = [author, "来源：\(platform)"]
        if let date = sources.compactMap(\.date).first,
           let formattedDate = Self.chineseDate(from: date) {
            components.append(formattedDate)
        }
        return components.joined(separator: " · ")
    }

    private static func chineseDate(from value: String) -> String? {
        let components = value.split(separator: "-").compactMap { Int($0) }
        guard components.count == 3 else { return nil }
        return "\(components[0])年\(components[1])月\(components[2])日"
    }
}

struct QuoteSource: Codable, Equatable {
    let name: String
    let url: String
    let sourceNumber: Int
    let date: String?
}
