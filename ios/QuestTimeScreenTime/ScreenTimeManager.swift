import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Native iOS locking foundation for QuestTime.
/// This source belongs in a SwiftUI iOS app target, not the GitHub Pages website.
/// Real blocking requires Apple's Family Controls entitlement and user authorization.
@MainActor
final class QuestTimeScreenTimeManager: ObservableObject {
    static let shared = QuestTimeScreenTimeManager()

    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selection = FamilyActivitySelection()

    private let store = ManagedSettingsStore(named: .init("QuestTime"))
    private let center = DeviceActivityCenter()

    private init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    /// Apply an actual iOS shield to the selected apps, categories, and web domains.
    /// Call this only after the user deliberately configures their lock list.
    func applyConfiguredShields() {
        guard authorizationStatus == .approved else { return }
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    /// Remove the shields after QuestTime has verified that a pass is allowed.
    /// Do not call this just because a UI button was tapped; validate the user's
    /// credit balance and active pass first, then persist the transaction.
    func clearConfiguredShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    /// Start a DeviceActivity interval so a native DeviceActivityMonitor extension
    /// can re-apply shields when the allowance ends. Add the monitor extension and
    /// implement intervalDidEnd in that extension before relying on this in production.
    func schedulePassEnd(after minutes: Int, activityName: String = "QuestTimePass") throws {
        guard minutes > 0 else { return }
        let duration = max(1, min(minutes, 24 * 60))
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let endDate = Calendar.current.date(byAdding: .minute, value: duration, to: Date()) ?? Date().addingTimeInterval(TimeInterval(duration * 60))
        let end = Calendar.current.dateComponents([.hour, .minute], from: endDate)
        let startComponents = DateComponents(hour: now.hour, minute: now.minute)
        let endComponents = DateComponents(hour: end.hour, minute: end.minute)
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        try center.startMonitoring(
            DeviceActivityName(activityName),
            during: schedule,
            events: [:]
        )
    }
}
