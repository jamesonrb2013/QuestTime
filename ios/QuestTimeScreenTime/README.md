# QuestTime native iOS Screen Time foundation

This folder contains source for the native app-lock foundation. GitHub Pages cannot block other iPhone apps; real blocking requires a signed native iOS app, explicit Screen Time authorization, and Apple's Family Controls entitlement.

## Implemented source

- `ScreenTimeManager.swift`: requests individual authorization, stores the selected FamilyActivitySelection in an App Group, applies/clears shields, and schedules a one-shot DeviceActivity interval for a pass.
- `QuestTimeLockSetupView.swift`: app picker and manual shield setup UI.
- `QuestTimeDeviceActivityMonitor.swift`: monitor extension callback that reloads the shared selection and re-applies shields when the QuestTime pass interval ends.

## Required Xcode configuration

1. On a Mac, create/open the SwiftUI iOS app project and add the manager and view files to the app target.
2. Add a separate **Device Activity Monitor Extension** target and add `QuestTimeDeviceActivityMonitor.swift` to that extension target only.
3. In **Signing & Capabilities**, enable **Family Controls** for the app and the monitor extension. Apple's approval is required for the Family Controls distribution entitlement before public/TestFlight distribution.
4. Enable the same **App Groups** capability for both targets and add this exact identifier to both: `group.com.onekidgaming.questtime`. If your Apple team does not permit this identifier, change the constant in both Swift files to the same App Group identifier that your team owns.
5. Set the app's bundle identifier and signing team. Build and test on a physical iPhone with the required entitlement.
6. In the app, request Screen Time access, choose apps, then apply the shield. Test a short pass end-to-end and verify that the monitor extension re-applies shields after the interval ends.
7. Before connecting coin purchases, implement trusted server-side pass validation and durable transaction records. Never put a Supabase service-role key in the app or website.

## Important limits / remaining work

- These files are source code, not a complete Xcode project or installable app. A Mac/Xcode and valid signing are still required to build, install, and test on an iPhone.
- Apple must approve the Family Controls entitlement for distribution. A GitHub Actions macOS runner does not bypass signing or entitlement approval.
- The monitor's one-shot schedule must be tested for short passes, intervals crossing midnight, time-zone changes, app restarts, and OS scheduling behavior. Do not claim production enforcement until those tests pass.
- The current website keeps coin balances in client-side save data. That is not tamper-proof and must not be treated as trusted payment/authorization for real app unlocking.
