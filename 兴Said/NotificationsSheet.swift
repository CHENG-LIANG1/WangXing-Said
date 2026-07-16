//
//  NotificationsSheet.swift
//  兴曰
//

import Foundation
import SwiftUI

struct NotificationsSheet: View {
    @Binding var mode: String
    @Binding var randomStartTime: String
    @Binding var randomEndTime: String
    @Binding var scheduledTime: String
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
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            SettingsLabel(systemName: "clock.arrow.2.circlepath", title: "发送区间")

                            Spacer()

                            Label("每天 2 条", systemImage: "sparkles")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 12) {
                            timeField(title: "开始", selection: randomStartDate)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.tertiary)

                            timeField(title: "结束", selection: randomEndDate)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 15)

                case "scheduled":
                    HStack(spacing: 16) {
                        SettingsLabel(systemName: "clock", title: "发送时间")

                        Spacer()

                        DatePicker(
                            "发送时间",
                            selection: scheduledDate,
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
                HapticFeedback.tap()
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
            .adaptiveInteractiveGlass(in: Capsule())
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
                HapticFeedback.success()
                testMessage = "测试通知将在一秒后送达"
            case .denied:
                HapticFeedback.error()
                testMessage = "请先在系统设置中允许通知"
            case .failed:
                HapticFeedback.error()
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
            return "每天在选定区间内随机发送两条语录"
        }
    }

    private func timeField(title: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            DatePicker(
                title,
                selection: selection,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var randomStartDate: Binding<Date> {
        timeBinding(for: $randomStartTime, fallback: "09:00")
    }

    private var randomEndDate: Binding<Date> {
        timeBinding(for: $randomEndTime, fallback: "21:00")
    }

    private var scheduledDate: Binding<Date> {
        timeBinding(for: $scheduledTime, fallback: "10:00")
    }

    private func timeBinding(for value: Binding<String>, fallback: String) -> Binding<Date> {
        Binding(
            get: {
                Self.timeFormatter.date(from: value.wrappedValue)
                    ?? Self.timeFormatter.date(from: fallback)
                    ?? Date()
            },
            set: { newValue in
                HapticFeedback.selection()
                value.wrappedValue = Self.timeFormatter.string(from: newValue)
            }
        )
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
