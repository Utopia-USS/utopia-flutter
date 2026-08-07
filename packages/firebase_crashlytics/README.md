<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/firebase_crashlytics/docs/header.png" width="375" alt="Utopia Firebase Crashlytics"/>

# utopia_firebase_crashlytics

Firebase Crashlytics integration for [utopia_reporter](https://github.com/Utopia-USS/utopia-flutter/tree/master/packages/reporter). Provides [`CrashlyticsReporter`][CrashlyticsReporter], a [`Reporter`][Reporter] implementation that records errors to Crashlytics and logs warnings/info as Crashlytics log entries. Also exposes [`UtopiaFirebaseCrashlytics.setup()`][setup] to disable collection in debug builds, and [`UtopiaFirebaseCrashlytics.ensure()`][ensure] for safe access to `FirebaseCrashlytics.instance` before Firebase finishes initialising.

## Usage

Call [`setup()`][setup] during app startup (after `Firebase.initializeApp`), then pass [`CrashlyticsReporter`][CrashlyticsReporter] wherever a [`Reporter`][Reporter] is expected:

```dart
await Firebase.initializeApp();
await UtopiaFirebaseCrashlytics.setup();

// Use directly or combine with other reporters
final reporter = Reporter.combined([
  CrashlyticsReporter(),
  LoggerReporter(),
]);
```

[CrashlyticsReporter]: https://pub.dev/documentation/utopia_firebase_crashlytics/latest/utopia_firebase_crashlytics/CrashlyticsReporter-class.html
[Reporter]: https://pub.dev/documentation/utopia_reporter/latest/utopia_reporter/Reporter-class.html
[setup]: https://pub.dev/documentation/utopia_firebase_crashlytics/latest/utopia_firebase_crashlytics/UtopiaFirebaseCrashlytics/setup.html
[ensure]: https://pub.dev/documentation/utopia_firebase_crashlytics/latest/utopia_firebase_crashlytics/UtopiaFirebaseCrashlytics/ensure.html
