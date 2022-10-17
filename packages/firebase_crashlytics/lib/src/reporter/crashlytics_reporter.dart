import 'package:flutter/cupertino.dart';
import 'package:utopia_firebase_crashlytics/utopia_firebase_crashlytics.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CrashlyticsReporter extends Reporter {
  const CrashlyticsReporter();

  @override
  void flutterError(FlutterErrorDetails details) =>
      UtopiaFirebaseCrashlytics.ensure((crashlytics) => crashlytics.recordFlutterError(details));

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    UtopiaFirebaseCrashlytics.ensure((crashlytics) {
      final effectiveMessage = sanitizedMessage ?? message;
      crashlytics.recordError(e ?? effectiveMessage, s, reason: effectiveMessage);
    });
  }

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _log(message, e, sanitizedMessage);

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) => _log(message, e, sanitizedMessage);

  void _log(String message, Object? e, String? sanitizedMessage) {
    UtopiaFirebaseCrashlytics.ensure((crashlytics) {
      final effectiveMessage = (sanitizedMessage ?? message) + (e != null ? " --- $e" : "");
      crashlytics.log(effectiveMessage);
    });
  }
}
