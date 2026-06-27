//
//  AppActions.swift
//  Pace
//

import Foundation

extension Notification.Name {
    static let showDashboard = Notification.Name("pace.showDashboard")
    static let openSettings = Notification.Name("pace.openSettings")
    static let dashboardNavigate = Notification.Name("pace.dashboardNavigate")
    static let createNewTask = Notification.Name("pace.createNewTask")
    static let createNewEvent = Notification.Name("pace.createNewEvent")
    static let beginCreateEvent = Notification.Name("pace.beginCreateEvent")
    static let toggleSidebar = Notification.Name("pace.toggleSidebar")
    static let focusNewTask = Notification.Name("pace.focusNewTask")
}

enum DashboardNavigationTarget: String {
    case home
    case calendar
    case tasks
    case playlists
    case settings
}
