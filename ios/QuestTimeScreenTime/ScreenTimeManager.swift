import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Native iOS locking foundation for QuestTime.
/// Real blocking requires Apple's Family Controls entitlement and user authorization.
@MainActor
final class QuestTimeScreenTimeManager: ObservableObject {
    static let shared = QuestTimeScreenTimeManager()

    /// This exact App Group must be enabled for BOTH the app and Device Activity Monitor
    /// extension targets under Signing & Capabilities.
    static let appGroupIdentifier = "group.com.onekidgaming.questtime"
    static let selectionStorageKey = "questtime.familyActivitySelection.v1"

    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selection = FamilyActivitySelection() {
        didSet { persistSelectionForMonitor() }
    }

    private let store = ManagedSettingsStore(named: .init("QuestTime"))
    private let center = DeviceActivityCenter()

    private init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        restoreSelection()
    }

    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    /// Save the selected tokens where the monitor extension can read them after this app closes.
    private func persistSelectionForMonitor() {
        guard let defaults = UserDefaults(suiteName: Self.appGroupIdentifier),
              let data = try? JSONEncoder().encode(selection) else { return }
        defaults.set(data, forKey: Self.selectionStorageKey)
    }

    private func restoreSelection() {
        guard let defaults = UserDefaults(suiteName: Self.appGroupIdentifier),
              let data = defaults.data(forKey: Self.selectionStorageKey),
              let restored = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }
        selection = restored
    }

    /// Apply actual iOS shields to the apps, categories, and web domains the user selected.
    func applyConfiguredShields() {
        guard authorizationStatus == .approved else { return }
        persistSelectionForMonitor()
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    /// Clear QuestTime's shields. Only call after a pass is legitimately granted.
    /// A production build must validate the pass with a trusted backend first.
    func clearConfiguredShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    /// Schedule a one-shot DeviceActivity interval. When it ends, the extension re-applies
    /// the saved selection. Verify this behavior on a physical device before production use.
    func schedulePassEnd(after minutes: Int, activityName: String = "QuestTimePass") throws {
        guard authorizationStatus == .approved, minutes > 0 else { return }
        persistSelectionForMonitor()

        let duration = max(1, min(minutes, 24 * 60))
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let endDate = Calendar.current.date(byAdding: .minute, value: duration, to: Date())
            ?? Date().addingTimeInterval(TimeInterval(duration * 60))
        let end = Calendar.current.dateComponents([.hour, .minute], from: endDate)
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: now.hour, minute: now.minute),
            intervalEnd: DateComponents(hour: end.hour, minute: end.minute),
            repeats: false
        )
        try center.startMonitoring(DeviceActivityName(activityName), during: schedule, events: [:])
    }
}
