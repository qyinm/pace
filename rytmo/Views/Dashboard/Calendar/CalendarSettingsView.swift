import SwiftUI

struct CalendarSettingsView: View {
    @StateObject private var calendarManager = CalendarManager.shared
    @StateObject private var googleCalendarManager = GoogleCalendarManager.shared
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Connected Calendars")
                .font(.title2)
                .fontWeight(.bold)

            Text("View events with read access. Creating or editing events requires write permission for each source.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                ToggleRow(
                    title: "System Calendar",
                    subtitle: systemCalendarSubtitle,
                    icon: "apple.logo",
                    isOn: Binding(
                        get: { calendarManager.showSystem },
                        set: { calendarManager.toggleSource(system: $0) }
                    )
                )

                if !calendarManager.isAuthorized && calendarManager.showSystem {
                    permissionActionRow(
                        message: "System calendar access not granted. Events cannot be viewed or edited.",
                        buttonTitle: "Grant Access"
                    ) {
                        Task { await calendarManager.requestAccess() }
                    }
                } else if calendarManager.isAuthorized && calendarManager.showSystem {
                    statusRow(
                        icon: "checkmark.circle.fill",
                        tint: .green,
                        message: "Read and write access granted"
                    )
                }

                Divider()

                ToggleRow(
                    title: "Google Calendar",
                    subtitle: googleCalendarSubtitle,
                    icon: "g.circle.fill",
                    isOn: Binding(
                        get: { calendarManager.showGoogle },
                        set: { calendarManager.toggleSource(google: $0) }
                    )
                )

                if googleCalendarManager.isLoading {
                    statusRow(
                        icon: "arrow.triangle.2.circlepath",
                        tint: .blue,
                        message: "Connecting to Google Calendar..."
                    )
                } else if let error = googleCalendarManager.error {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Retry") {
                            Task { await googleCalendarManager.requestAccess() }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                } else if googleCalendarManager.canWriteEvents && calendarManager.showGoogle {
                    HStack(alignment: .center) {
                        statusRow(
                            icon: "checkmark.circle.fill",
                            tint: .green,
                            message: "Connected • read and write • \(googleCalendarManager.events.count) cached events"
                        )
                        Spacer(minLength: 12)
                        Button("Disconnect") {
                            googleCalendarManager.disconnect()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(Color.green.opacity(0.05))
                } else if googleCalendarManager.needsScopeUpgrade && calendarManager.showGoogle {
                    VStack(alignment: .leading, spacing: 10) {
                        statusRow(
                            icon: "eye.fill",
                            tint: .orange,
                            message: "Connected • read-only • \(googleCalendarManager.events.count) cached events"
                        )
                        Text("Upgrade to the full calendar scope to create, edit, or delete Google events.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Button("Enable Editing") {
                                Task { await googleCalendarManager.requestScopeUpgrade() }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)

                            Button("Disconnect") {
                                googleCalendarManager.disconnect()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.08))
                } else if googleCalendarManager.isAuthorized && calendarManager.showGoogle {
                    HStack(alignment: .center) {
                        statusRow(
                            icon: "eye.fill",
                            tint: .blue,
                            message: "Connected • read-only • \(googleCalendarManager.events.count) cached events"
                        )
                        Spacer(minLength: 12)
                        Button("Disconnect") {
                            googleCalendarManager.disconnect()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                } else if !googleCalendarManager.isAuthorized && calendarManager.showGoogle {
                    permissionActionRow(
                        message: "Google Calendar is not connected. Sign in and grant calendar access to view events.",
                        buttonTitle: "Connect Google"
                    ) {
                        Task { await googleCalendarManager.requestAccess() }
                    }
                }
            }
            .background(Color.primary.opacity(0.03))
            .cornerRadius(12)

            Spacer()
        }
        .padding(32)
        .onAppear {
            calendarManager.checkPermission()
        }
    }

    private var systemCalendarSubtitle: String {
        if calendarManager.isAuthorized {
            return "Apple Calendar with read and write access"
        }
        return "Apple Calendar — permission required"
    }

    private var googleCalendarSubtitle: String {
        if googleCalendarManager.canWriteEvents {
            return "Google API with read and write access"
        }
        if googleCalendarManager.isAuthorized {
            return "Google API with read-only access"
        }
        return "Google API — connect to view events"
    }

    @ViewBuilder
    private func permissionActionRow(message: String, buttonTitle: String, action: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
            Spacer()
            Button(buttonTitle) {
                action()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
    }

    @ViewBuilder
    private func statusRow(icon: String, tint: Color, message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(tint)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    struct ToggleRow: View {
        let title: String
        let subtitle: String
        let icon: String
        @Binding var isOn: Bool

        var body: some View {
            Toggle(isOn: $isOn) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 14, weight: .medium))
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .toggleStyle(.switch)
        }
    }
}