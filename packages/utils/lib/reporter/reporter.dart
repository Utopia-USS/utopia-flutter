import 'package:flutter/cupertino.dart';

abstract class Reporter {
  const Reporter();

  void flutterError(FlutterErrorDetails details) => error(details.toString(), details.exception, details.stack);

  void error(String message, [Object? error, StackTrace? stackTrace]) {}

  void warning(String message, [Object? error, StackTrace? stackTrace]) {}

  void info(String message, [Object? error, StackTrace? stackTrace]) {}

  static Reporter combine(List<Reporter> reporters) => _CombinedReporter(reporters);
}

class _CombinedReporter extends Reporter {
  final List<Reporter> _reporters;

  const _CombinedReporter(this._reporters);

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _reporters.forEach((reporter) => reporter.error(message, error, stackTrace));

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _reporters.forEach((reporter) => reporter.warning(message, error, stackTrace));

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) =>
      _reporters.forEach((reporter) => reporter.info(message, error, stackTrace));
}
