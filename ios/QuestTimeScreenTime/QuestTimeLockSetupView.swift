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
                Section("Screen Time permission") {
                    Text("QuestTime can shield only the apps, categories, and websites you choose. You can change this list later.")
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

                Section("Choose what to lock") {
                    Button("Choose apps and websites") { showingPicker = true }
                    Text("\(manager.selection.applicationTokens.count) apps, \(manager.selection.categoryTokens.count) categories, and \(manager.selection.webDomainTokens.count) websites selected")
                        .font(.footnote)
                    Button("Shield selected apps now") {
                        guard manager.authorizationStatus == .approved else {
                            message = "Enable Screen Time access first."
                            return
                        }
                        guard !manager.selection.applicationTokens.isEmpty
                                || !manager.selection.categoryTokens.isEmpty
                                || !manager.selection.webDomainTokens.isEmpty else {
                            message = "Choose at least one app, category, or website first."
                            return
                        }
                        manager.applyConfiguredShields()
                        message = "QuestTime shields are active for your selected items."
                    }
                }

                Section("Timed pass test") {
                    Text("This local test temporarily removes QuestTime's shields, then the monitor extension should re-apply them after 15 minutes. It does not spend coins or validate a real reward yet.")
                        .font(.footnote)
                    Button("Start 15-minute test pass") {
                        guard manager.authorizationStatus == .approved else {
                            message = "Enable Screen Time access first."
                            return
                        }
                        guard !manager.selection.applicationTokens.isEmpty
                                || !manager.selection.categoryTokens.isEmpty
                                || !manager.selection.webDomainTokens.isEmpty else {
                            message = "Choose at least one app, category, or website first."
                            return
                        }
                        do {
                            try manager.schedulePassEnd(after: 15)
                            manager.clearConfiguredShields()
                            message = "Test pass started. QuestTime should re-shield your selection after 15 minutes."
                        } catch {
                            message = "Could not schedule the pass timer: \(error.localizedDescription). Shields were not cleared."
                        }
                    }
                    Button("End test pass and lock now", role: .destructive) {
                        manager.applyConfiguredShields()
                        message = "QuestTime shields were applied again."
                    }
                }
            }
            .navigationTitle("QuestTime App Lock")
            .familyActivityPicker(isPresented: $showingPicker, selection: $manager.selection)
        }
    }
}
