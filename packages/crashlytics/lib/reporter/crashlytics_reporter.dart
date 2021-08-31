import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/reporter/reporter.dart';

class CrashlyticsReporter extends Reporter {
  const CrashlyticsReporter();

  @override
  void flutterError(FlutterErrorDetails details) {
    if(_isFirebaseInitialized) FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isFirebaseInitialized) {
      FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace, reason: message);
    }
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) => _log(message);

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) => _log(message);

  void _log(String message) {
    if (_isFirebaseInitialized) {
      FirebaseCrashlytics.instance.log(message);
    }
  }

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;
}
