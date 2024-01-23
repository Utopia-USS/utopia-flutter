import 'package:utopia_reporter/src/reporter.dart';
import 'package:utopia_utils/utopia_utils.dart';

final class PrefixedReporter extends Reporter {
  final Reporter reporter;
  final String prefix;

  const PrefixedReporter(this.reporter, this.prefix);

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
