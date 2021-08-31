import 'package:logger/logger.dart';
import 'package:utopia_utils/reporter/reporter.dart';

class LoggerReporter extends Reporter {
  final logger = Logger();

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) => logger.e(message, error, stackTrace);

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) => logger.w(message, error, stackTrace);

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) => logger.i(message, error, stackTrace);
}