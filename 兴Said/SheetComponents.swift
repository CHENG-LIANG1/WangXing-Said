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

struct SegmentOption: Identifiable {
    let id: String
    let title: String
}

struct GlassSegmentedControl: View {
    @Binding var selection: String
    let options: [SegmentOption]

    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 3) {
            ForEach(options) { option in
                Button {
                    withAnimation(.snappy(duration: 0.30, extraBounce: 0.04)) {
                        selection = option.id
                    }
                } label: {
                    Text(option.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(selection == option.id ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if selection == option.id {
                                Capsule()
                                    .fill(selectionFill)
                                    .matchedGeometryEffect(id: "选中项", in: selectionNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == option.id ? .isSelected : [])
            }
        }
        .padding(4)
        .glassEffect(.regular.interactive(), in: Capsule())
        .sensoryFeedback(.selection, trigger: selection)
    }

    private var selectionFill: Color {
        colorScheme == .dark ? .white.opacity(0.16) : .white.opacity(0.42)
    }
}
