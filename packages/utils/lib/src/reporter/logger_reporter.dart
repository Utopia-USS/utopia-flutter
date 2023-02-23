import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:utopia_utils/utopia_utils.dart';

class LoggerReporter extends Reporter {
  final Logger _logger;

  LoggerReporter({bool forceEnabled = false}) : _logger = _buildDefaultLogger(forceEnabled: forceEnabled);

  const LoggerReporter.custom(this._logger);

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) => _logger.e(message, e, s);

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) => _logger.w(message, e, s);

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    _logger.i(
      message,
      e,
      s ?? StackTrace.empty, // more sensible behaviour - info messages usually do not require a stack trace
    );
  }

  static Logger _buildDefaultLogger({required bool forceEnabled}) {
    return Logger(
      filter: forceEnabled ? ProductionFilter() : DevelopmentFilter(),
      printer: PrettyPrinter(errorMethodCount: kDebugMode ? _maxMethodCount : 8),
    );
  }

  static const _maxMethodCount = 0xFFFFFFFFFFFFFFFF;
}
