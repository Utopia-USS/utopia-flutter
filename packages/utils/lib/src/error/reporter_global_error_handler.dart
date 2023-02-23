import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/src/error/global_error_handler.dart';
import 'package:utopia_utils/src/reporter/reporter.dart';

class ReporterGlobalErrorHandler implements GlobalErrorHandler {
  final Reporter reporter;
  
  const ReporterGlobalErrorHandler(this.reporter);

  @override
  void onOtherError(Object error, StackTrace? stackTrace) => reporter.error("Uncaught error", e: error, s: stackTrace);

  @override
  void onFlutterError(FlutterErrorDetails details) => reporter.flutterError(details);

  @override
  void onSerializedError(String error, StackTrace? stackTrace) => onOtherError(error, stackTrace);
}
