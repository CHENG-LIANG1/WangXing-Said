//
//  AdaptiveEffects.swift
//  兴曰
//

import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveInteractiveGlass<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.interactive(), in: shape)
        } else {
            background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape
                        .stroke(.white.opacity(0.28), lineWidth: 0.8)
                }
        }
    }

    @ViewBuilder
    func adaptiveSheetGlass<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: shape)
                .overlay {
                    shape.stroke(.white.opacity(0.38), lineWidth: 0.8)
                }
        } else {
            background(.regularMaterial, in: shape)
                .overlay {
                    shape.stroke(.white.opacity(0.30), lineWidth: 0.8)
                }
        }
    }

    @ViewBuilder
    func adaptiveQuotePaging() -> some View {
        if #available(iOS 26.0, *) {
            scrollTargetBehavior(
                .viewAligned(limitBehavior: .alwaysByOne, anchor: .top)
            )
        } else {
            scrollTargetBehavior(.paging)
        }
    }
}
