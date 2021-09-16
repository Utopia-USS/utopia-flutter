import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/reporter/reporter.dart';

class CrashlyticsReporter extends Reporter {
  const CrashlyticsReporter();

  @override
  void flutterError(FlutterErrorDetails details) {
    if (_isFirebaseInitialized) FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    if (_isFirebaseInitialized) {
      final effectiveMessage = sanitizedMessage ?? message;
      FirebaseCrashlytics.instance.recordError(e ?? effectiveMessage, s, reason: effectiveMessage);
    }
  }

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _log(message, sanitizedMessage);

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) =>
      _log(message, sanitizedMessage);

  void _log(String message, String? sanitizedMessage) {
    if (_isFirebaseInitialized) {
      final effectiveMessage = sanitizedMessage ?? message;
      FirebaseCrashlytics.instance.log(effectiveMessage);
    }
  }

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;
}
