import 'package:utopia_reporter/src/combined_reporter.dart';
import 'package:utopia_reporter/src/prefixed_reporter.dart';

abstract base class Reporter {
  const Reporter();

  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {}

  const factory Reporter.combined(List<Reporter> reporters) = CombinedReporter;

  const factory Reporter.prefixed(Reporter reporter, String prefix) = PrefixedReporter;
}
