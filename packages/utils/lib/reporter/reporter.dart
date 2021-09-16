import 'package:flutter/cupertino.dart';

abstract class Reporter {
  const Reporter();

  void flutterError(FlutterErrorDetails details) =>
      error(details.toString(), e: details.exception, s: details.stack);

  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  static Reporter combine(List<Reporter> reporters) => _CombinedReporter(reporters);
}

class _CombinedReporter extends Reporter {
  final List<Reporter> _reporters;

  const _CombinedReporter(this._reporters);

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    _reporters.forEach(
      (reporter) => reporter.error(message, e: e, s: s, sanitizedMessage: sanitizedMessage),
    );
  }

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    _reporters.forEach(
      (reporter) => reporter.warning(message, e: e, s: s, sanitizedMessage: sanitizedMessage),
    );
  }

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    _reporters.forEach(
      (reporter) => reporter.info(message, e: e, s: s, sanitizedMessage: sanitizedMessage),
    );
  }
}
