import 'package:logger/logger.dart';
import 'package:utopia_utils/utopia_utils.dart';

class LoggerReporter extends Reporter {
  final _logger = Logger();

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _logger.e(message, e, s);

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _logger.w(message, e, s);

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _logger.i(message, e, s);
}