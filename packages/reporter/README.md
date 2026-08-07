<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/reporter/docs/header.png" width="251" alt="Utopia Reporter"/>

# utopia_reporter

A lightweight reporting abstraction for Dart and Flutter. Define a single [`Reporter`][Reporter] dependency in your app and swap implementations (local logging, crash reporting services, etc.) without touching call sites.

## Core API

[`Reporter`][Reporter] is an abstract base class with three methods, all with optional named parameters for the original exception and stack trace, plus a `sanitizedMessage` for backends that should not receive raw user data:

```dart
abstract base class Reporter {
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage});
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage});
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage});
}
```

## Built-in implementations

| Class | Description |
|---|---|
| [`LoggerReporter`][LoggerReporter] | Delegates to a [`logger`](https://pub.dev/packages/logger) instance. [`LoggerReporter.standard()`][LoggerReporter.standard] builds a sane default with `PrettyPrinter`; pass `forceEnabled: true` to keep it active in release mode. |
| [`Reporter.combined(reporters)`][Reporter.combined] | Fan-out: forwards every call to a list of reporters. Useful for sending to both a logger and a crash-reporting backend at once. |
| [`Reporter.prefixed(reporter, prefix)`][Reporter.prefixed] | Wraps another reporter and prepends a fixed string to every message (and `sanitizedMessage`), handy for tagging events by feature or module. |

## Implementing your own

Extend [`Reporter`][Reporter] and override whichever methods you need. The base class provides empty default implementations, so you only override what matters:

```dart
final class MyCrashReporter extends Reporter {
  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    // send to your crash service
  }
}
```

Combine it with the local logger during development:

```dart
final reporter = Reporter.combined([
  LoggerReporter.standard(),
  MyCrashReporter(),
]);
```

[Reporter]: https://pub.dev/documentation/utopia_reporter/latest/utopia_reporter/Reporter-class.html
[LoggerReporter]: https://pub.dev/documentation/utopia_reporter/latest/utopia_reporter/LoggerReporter-class.html
[LoggerReporter.standard]: https://pub.dev/documentation/utopia_reporter/latest/utopia_reporter/LoggerReporter/LoggerReporter.standard.html
[Reporter.combined]: https://pub.dev/documentation/utopia_reporter/latest/utopia_reporter/Reporter/Reporter.combined.html
[Reporter.prefixed]: https://pub.dev/documentation/utopia_reporter/latest/utopia_reporter/Reporter/Reporter.prefixed.html
