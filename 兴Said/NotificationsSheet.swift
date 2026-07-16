//
//  NotificationsSheet.swift
//  兴曰
//

import Foundation
import SwiftUI

struct NotificationsSheet: View {
    @Binding var mode: String
    @Binding var cadence: String
    @Binding var time: String
    let onTest: () async -> TestNotificationResult

    @State private var isSendingTest = false
    @State private var testMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "通知", subtitle: notificationSummary)

            Divider()
                .opacity(0.45)

            VStack(alignment: .leading, spacing: 12) {
                Text("接收方式")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                GlassSegmentedControl(
                    selection: $mode,
                    options: [
                        SegmentOption(id: "off", title: "关闭"),
                        SegmentOption(id: "random", title: "随机"),
                        SegmentOption(id: "scheduled", title: "定时")
                    ]
                )
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 16)

            Divider()
                .padding(.leading, 22)

            Group {
                switch mode {
                case "random":
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsLabel(systemName: "calendar", title: "发送频率")

                        GlassSegmentedControl(
                            selection: $cadence,
                            options: [
                                SegmentOption(id: "daily", title: "每天"),
                                SegmentOption(id: "2days", title: "每两天"),
                                SegmentOption(id: "weekly", title: "每周")
                            ]
                        )
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 15)

                case "scheduled":
                    HStack(spacing: 16) {
                        SettingsLabel(systemName: "clock", title: "发送时间")

                        Spacer()

                        DatePicker(
                            "发送时间",
                            selection: notificationDate,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)

                default:
                    HStack(spacing: 12) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Text("通知已关闭")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))

                        Spacer()
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .top)
            .transition(.opacity.combined(with: .move(edge: .top)))

            Spacer(minLength: 8)

            testButton
        }
        .animation(.snappy(duration: 0.28), value: mode)
        .animation(.easeInOut(duration: 0.2), value: testMessage)
    }

    private var testButton: some View {
        VStack(spacing: 8) {
            Button {
                sendTestNotification()
            } label: {
                HStack(spacing: 9) {
                    if isSendingTest {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 16, weight: .bold))
                    }

                    Text(isSendingTest ? "正在发送" : "试一试")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .glassEffect(.regular.interactive(), in: Capsule())
            .disabled(isSendingTest)

            if let testMessage {
                Text(testMessage)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 14)
    }

    private func sendTestNotification() {
        guard !isSendingTest else { return }

        isSendingTest = true
        testMessage = nil

        Task {
            let result = await onTest()
            isSendingTest = false

            switch result {
            case .scheduled:
                testMessage = "测试通知将在一秒后送达"
            case .denied:
                testMessage = "请先在系统设置中允许通知"
            case .failed:
                testMessage = "发送失败，请稍后再试"
            }
        }
    }

    private var notificationSummary: String {
        switch mode {
        case "off":
            return "当前不会发送语录"
        case "scheduled":
            return "按设定的时间发送语录"
        default:
            return "随机为你送上一句语录"
        }
    }

    private var notificationDate: Binding<Date> {
        Binding(
            get: {
                Self.timeFormatter.date(from: time) ?? Self.defaultNotificationDate
            },
            set: { newValue in
                time = Self.timeFormatter.string(from: newValue)
            }
        )
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let defaultNotificationDate = timeFormatter.date(from: "10:00") ?? Date()
}
