import 'package:flutter/cupertino.dart';
import 'package:utopia_arch/src/error/global_error_handler.dart';
import 'package:utopia_utils/utopia_utils.dart';

class ReporterGlobalErrorHandler implements GlobalErrorHandler {
  final Reporter reporter;

  const ReporterGlobalErrorHandler(this.reporter);

  @override
  void onOtherError(Object error, StackTrace? stackTrace) => reporter.error("Uncaught error", e: error, s: stackTrace);

  @override
  void onFlutterError(FlutterErrorDetails details) =>
      reporter.error(details.toString(), e: details.exception, s: details.stack);

  @override
  void onSerializedError(String error, StackTrace? stackTrace) => onOtherError(error, stackTrace);
}
