# SafeTap iOS App

SafeTap is a SwiftUI emergency alert prototype for iOS. The app opens as a calculator-style disguise, then reveals an emergency dashboard after a hidden interaction. From the dashboard or an App Shortcut, a user can trigger SOS mode, start audio recording, share location updates, write incident records to Firebase, and notify linked SafeTap contacts through shared incident data.

## Features

- Calculator disguise screen with hidden dashboard unlock.
- Anonymous Firebase Authentication for each installed user.
- User profile setup with a display name and SafeTap user ID.
- Emergency contact management with optional linked SafeTap IDs.
- SOS activation from the dashboard or App Shortcuts.
- Audio recording during active SOS sessions.
- Live location updates while SOS recording is active.
- Firebase Realtime Database incident history and shared incident indexing.
- Firebase Storage upload for emergency recordings.
- Local notifications when a linked contact receives a shared active incident.
- Cancellation and resolved-state handling for accidental or completed incidents.

## Project Structure

```text
iOSApp/
├── iOSApp/
│   ├── Assets.xcassets
│   ├── CloudManager.swift
│   ├── ContentView.swift
│   ├── GoogleService-Info.plist
│   ├── help.jpg
│   ├── Info.plist
│   ├── iOSAppApp.swift
│   ├── LocalNotificationManager.swift
│   ├── PowerButtonDetector.swift
│   ├── SafeTapAppDelegate.swift
│   ├── SOSAppShortcuts.swift
│   ├── SOSManager.swift
│   └── UserSessionManager.swift
└── Products/
    └── SafeTap.app
```

## Main Files

| File | Purpose |
| --- | --- |
| `iOSAppApp.swift` | App entry point. Configures Firebase and injects `UserSessionManager`. |
| `ContentView.swift` | Main SwiftUI interface, calculator disguise, emergency dashboard, contact editor, and supporting view models/extensions. |
| `SOSManager.swift` | Handles SOS activation, audio recording, location updates, and cancellation. |
| `CloudManager.swift` | Handles local contact/history persistence, Firebase incident writes, shared incident sync, and recording references. |
| `UserSessionManager.swift` | Handles anonymous Firebase sign-in, cached profile loading, and display name sync. |
| `LocalNotificationManager.swift` | Requests notification permission and schedules local notifications for shared incidents. |
| `SOSAppShortcuts.swift` | Defines the `Trigger SOS` App Intent for Shortcuts and Back Tap workflows. |
| `SafeTapAppDelegate.swift` | Configures notification handling during app launch. |
| `PowerButtonDetector.swift` | Experimental power-button-style trigger observer. This is not currently part of the reliable primary SOS flow. |

## Requirements

- Xcode 15 or later.
- iOS 17 SDK recommended.
- SwiftUI.
- Firebase configured for iOS.
- Firebase products used by the app:
  - Firebase Authentication
  - Firebase Realtime Database
  - Firebase Storage

## Setup

1. Open the project in Xcode.
2. Confirm `GoogleService-Info.plist` is included in the app target.
3. In Firebase Console, enable Anonymous Authentication.
4. Create or confirm the Realtime Database instance used by the app.
5. Create or confirm Firebase Storage rules for recording uploads.
6. Build and run the app on a real iPhone for full microphone, location, and background behavior.

The app currently points to this Realtime Database URL in `CloudManager.swift` and `UserSessionManager.swift`:

```text
https://safetap-2b38b-default-rtdb.asia-southeast1.firebasedatabase.app/
```

If you create a new Firebase project, update that database URL in both files and replace `GoogleService-Info.plist`.

## Required iOS Permissions

SafeTap uses microphone, location, and notifications. Make sure `Info.plist` contains appropriate usage descriptions before relying on device testing or App Store distribution.

Recommended keys:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>SafeTap records audio during an active SOS session.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>SafeTap shares your location with trusted contacts during an active SOS session.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>SafeTap can continue sharing location during an active SOS session.</string>
```

If background location or background recording is required, also configure the correct background modes in the app target capabilities and `Info.plist`.

## How The App Works

1. On first launch, the app signs in anonymously with Firebase.
2. The user enters a display name.
3. The app shows a calculator disguise by default.
4. Tapping `=` three times quickly unlocks the SafeTap dashboard.
5. The user adds emergency contacts. A contact can optionally include another user's SafeTap ID.
6. Triggering SOS creates an active incident, starts recording, writes alert data to Firebase, and starts location sharing.
7. Linked SafeTap contacts receive the incident in their Emergency workspace.
8. Contacts can acknowledge, request check-in, navigate to the latest location, or mark an incident resolved.
9. The owner can cancel an accidental SOS, which writes a cancellation event and stops recording.

## App Shortcut / Back Tap

`SOSAppShortcuts.swift` defines a `Trigger SOS` App Intent. On iPhone, users can connect this to Back Tap:

1. Open iPhone Settings.
2. Go to Accessibility > Touch > Back Tap.
3. Choose Triple Tap.
4. Select the `Trigger SOS` shortcut for SafeTap.

This flow depends on iOS Shortcuts/App Intents availability and device settings.

## Firebase Data Areas

The app writes or reads data under these Firebase paths:

- `users`
- `connections`
- `incidents`
- `incidentEvents`
- `incidentLocations`
- `incidentRecordings`
- `incidentResponses`
- `userIncidents`
- `liveLocation`
- `recordings`
- `alerts`

The current implementation writes alert records to Firebase. It does not send real SMS messages or remote push notifications by itself.

## Local Storage

The app stores some local state in `UserDefaults`:

- User profile cache.
- Emergency contacts.
- Incident history.
- Active incident ID.
- Dashboard mode.

For production use, consider moving privacy-sensitive or larger incident data into a more appropriate encrypted/persistent storage layer.

## Development Notes

- The app builds successfully in Xcode at the time this README was added.
- `ContentView.swift` is currently large and contains multiple views, models, and extensions. Splitting it into smaller files would make future maintenance easier.
- `PowerButtonDetector.swift` is experimental. iOS apps cannot reliably detect hardware power button presses directly.
- The calculator currently uses `NSExpression` for simple evaluation. A safer parser would be preferable for production.
- SOS recording currently stops automatically after 10 minutes.
- Location uploads are throttled to about one update every 20 seconds while recording.

## Testing Checklist

Before relying on a build, test these flows on a physical iPhone:

- First-launch anonymous sign-in.
- Profile setup.
- Microphone permission prompt.
- Location permission prompt.
- Notification permission prompt.
- Add, edit, and delete contacts.
- Add a linked SafeTap ID and verify shared incident sync.
- Trigger SOS from the dashboard.
- Trigger SOS from App Shortcuts or Back Tap.
- Confirm recording upload to Firebase Storage.
- Confirm incident events in Firebase Realtime Database.
- Confirm location updates during active SOS.
- Cancel an accidental SOS.
- Mark a shared incident resolved from Emergency mode.

## Known Limitations

- Firebase alert records are not the same as SMS or push delivery.
- Background behavior depends on device capabilities, app permissions, and configured background modes.
- Anonymous Firebase users are device/app-install based unless account linking is added.
- Local incident history may diverge from remote state if writes fail or the app is offline.
- The project does not currently include automated tests.

## Suggested Next Improvements

- Add automated tests for incident merging, contact deduplication, location parsing, and calculator evaluation.
- Split large SwiftUI files into focused views and models.
- Add a real notification delivery channel such as Firebase Cloud Messaging or an SMS provider.
- Harden Firebase security rules.
- Replace `UserDefaults` incident storage with a more robust local persistence approach.
- Improve SOS session lifecycle handling so timers and uploads are tied to a specific incident ID.
