# QuestTime native iOS Screen Time foundation

This folder is the beginning of the native iOS app-lock implementation. The GitHub Pages app cannot block other apps; iOS only permits this through Apple's Screen Time frameworks in a signed native app.

## What's here

- `ScreenTimeManager.swift`: requests individual Family Controls authorization, holds a `FamilyActivitySelection`, applies shields through `ManagedSettingsStore`, and includes a DeviceActivity scheduling starting point.

## Next steps in Xcode (required for real blocking)

1. On a Mac, create a SwiftUI iOS app named **QuestTime** and add this Swift file to the app target.
2. In Signing & Capabilities, add **Family Controls**. Apple must grant the Family Controls distribution entitlement before a public/TestFlight build can use it. A free GitHub Pages deploy does not provide this entitlement.
3. Add a SwiftUI screen using Apple's `FamilyActivityPicker` and bind it to `QuestTimeScreenTimeManager.shared.selection`. Let the user choose exactly which apps, categories, and web domains are shielded.
4. Request authorization after the user taps a clear “Enable app locking” action. Do not silently enable it.
5. Add a **Device Activity Monitor Extension** and implement `intervalDidEnd(for:)` to re-apply shields when a pass expires. Add a **Shield Configuration Extension** for the custom blocked-app screen and a **Shield Action Extension** for buttons on that screen.
6. Move credit/pass decisions to a trusted backend before public use. The current browser-side coin balance is game progress, not tamper-proof currency. Never put a Supabase service-role key in the app or website.
7. Connect sign-in and the user's selected app rules to Supabase. The website's App Lock page currently saves app choices, prices, and virtual passes in the user's QuestTime save.

## Important limitation

The Swift file is a foundation, not a complete installable iOS app. DeviceActivity schedules need careful handling across midnight/time-zone changes and a monitor extension; the example schedule is only a starting point. Test on a physical iPhone with the required entitlement and explicit authorization. Do not describe an app as truly locked until those tests pass.
