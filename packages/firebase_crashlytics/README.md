<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/firebase_crashlytics/docs/header.png" width="375" alt="Utopia Firebase Crashlytics"/>

# utopia_firebase_crashlytics

Firebase Crashlytics integration for [utopia_reporter](https://github.com/Utopia-USS/utopia-flutter/tree/master/packages/reporter). Provides `CrashlyticsReporter`, a `Reporter` implementation that records errors to Crashlytics and logs warnings/info as Crashlytics log entries. Also exposes `UtopiaFirebaseCrashlytics.setup()` to disable collection in debug builds, and `UtopiaFirebaseCrashlytics.ensure()` for safe access to `FirebaseCrashlytics.instance` before Firebase finishes initialising.

## Usage

Call `setup()` during app startup (after `Firebase.initializeApp`), then pass `CrashlyticsReporter` wherever a `Reporter` is expected:

```dart
await Firebase.initializeApp();
await UtopiaFirebaseCrashlytics.setup();

// Use directly or combine with other reporters
final reporter = Reporter.combined([
  CrashlyticsReporter(),
  LoggerReporter(),
]);
```
