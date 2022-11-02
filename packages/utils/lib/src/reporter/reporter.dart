import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract class Reporter {
  const Reporter();

  void flutterError(FlutterErrorDetails details) =>
      error(details.toString(), e: details.exception, s: details.stack);

  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  @Deprecated("Use the Reporter.combined factory constructor")
  static Reporter combine(List<Reporter> reporters) => _CombinedReporter(reporters);

  const factory Reporter.combined(List<Reporter> reporters) = _CombinedReporter;

  const factory Reporter.prefixed(Reporter reporter, String prefix) = _PrefixedReporter;
}

class _CombinedReporter extends Reporter {
  final List<Reporter> _reporters;

  const _CombinedReporter(this._reporters);

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    for (final reporter in _reporters) {
      reporter.error(message, e: e, s: s, sanitizedMessage: sanitizedMessage);
    }
  }

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    for (final reporter in _reporters) {
      reporter.warning(message, e: e, s: s, sanitizedMessage: sanitizedMessage);
    }
  }

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    for (final reporter in _reporters) {
      reporter.info(message, e: e, s: s, sanitizedMessage: sanitizedMessage);
    }
  }
}

class _PrefixedReporter extends Reporter {
  final Reporter reporter;
  final String prefix;

  const _PrefixedReporter(this.reporter, this.prefix);

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      reporter.error(prefix + message, e: e, s: s, sanitizedMessage: sanitizedMessage?.let((it) => prefix + it));

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      reporter.warning(prefix + message, e: e, s: s, sanitizedMessage: sanitizedMessage?.let((it) => prefix + it));

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      reporter.info(prefix + message, e: e, s: s, sanitizedMessage: sanitizedMessage?.let((it) => prefix + it));
}
