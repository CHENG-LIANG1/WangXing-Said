//
//  SheetComponents.swift
//  兴曰
//

import SwiftUI

struct SheetHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 22)
        .padding(.bottom, 16)
    }
}

struct SettingsLabel: View {
    let systemName: String
    let title: String

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 22)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
    }
}
