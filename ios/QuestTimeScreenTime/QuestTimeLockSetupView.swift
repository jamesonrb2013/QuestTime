import SwiftUI
import FamilyControls

/// Add this view to the native QuestTime iOS app target.
struct QuestTimeLockSetupView: View {
    @StateObject private var manager = QuestTimeScreenTimeManager.shared
    @State private var showingPicker = false
    @State private var message = "Choose the apps you want QuestTime to shield."

    var body: some View {
        NavigationStack {
            Form {
                Section("App locking permission") {
                    Text("QuestTime can shield only the apps and categories you choose. You can change this list later.")
                    Button("Enable Screen Time access") {
                        Task {
                            do {
                                try await manager.requestAuthorization()
                                message = "Screen Time access: \(manager.authorizationStatus == .approved ? "approved" : "not approved")"
                            } catch {
                                message = "Authorization failed: \(error.localizedDescription)"
                            }
                        }
                    }
                    Text(message).font(.footnote)
                }
                Section("Your locked-app list") {
                    Button("Choose apps and websites") { showingPicker = true }
                    Text("\(manager.selection.applicationTokens.count) apps, \(manager.selection.categoryTokens.count) categories, and \(manager.selection.webDomainTokens.count) websites selected")
                        .font(.footnote)
                }
                Section("Apply rules") {
                    Button("Shield selected apps now") {
                        manager.applyConfiguredShields()
                        message = "Selected apps are shielded on this device."
                    }
                    Button("Clear QuestTime shields", role: .destructive) {
                        manager.clearConfiguredShields()
                        message = "QuestTime shields were cleared."
                    }
                }
            }
            .navigationTitle("QuestTime App Lock")
            .familyActivityPicker(isPresented: $showingPicker, selection: $manager.selection)
        }
    }
}
