import DeviceActivity
import FamilyControls
import ManagedSettings
import Foundation

/// Add this file to a separate Device Activity Monitor Extension target.
/// Configure the same App Group on the app and this extension.
final class QuestTimeDeviceActivityMonitor: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: .init("QuestTime"))
    private let appGroupIdentifier = "group.com.onekidgaming.questtime"
    private let selectionStorageKey = "questtime.familyActivitySelection.v1"

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard activity.rawValue == "QuestTimePass" else { return }

        // Fail closed: restore the user's saved shields when the pass interval ends.
        // If shared data is missing/corrupt, do not clear any existing shields.
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: selectionStorageKey),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }
}
