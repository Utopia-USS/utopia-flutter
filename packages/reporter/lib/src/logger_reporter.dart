import 'package:logger/logger.dart';
import 'package:utopia_reporter/utopia_reporter.dart';

final class LoggerReporter extends Reporter {
  final Logger _logger;

  const LoggerReporter(this._logger);

  LoggerReporter.standard({bool forceEnabled = false}) : _logger = _buildStandardLogger(forceEnabled: forceEnabled);

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _logger.e(message, error: e, stackTrace: s);

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _logger.w(message, error: e, stackTrace: s);

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    _logger.i(
      message,
      error: e,
      stackTrace: s ?? StackTrace.empty, // more sensible behaviour - info messages usually do not require a stack trace
    );
  }

  static Logger _buildStandardLogger({required bool forceEnabled}) {
    return Logger(
      filter: forceEnabled ? ProductionFilter() : DevelopmentFilter(),
      printer: PrettyPrinter(errorMethodCount: _maxMethodCount),
    );
  }

  static const _maxMethodCount = 10000;
}
