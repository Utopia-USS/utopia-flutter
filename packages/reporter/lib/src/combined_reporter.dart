import 'package:utopia_reporter/src/reporter.dart';

final class CombinedReporter extends Reporter {
  final List<Reporter> _reporters;

  const CombinedReporter(this._reporters);

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
