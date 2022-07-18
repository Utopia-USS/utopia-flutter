import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CrashlyticsReporter extends Reporter {
  const CrashlyticsReporter();

  @override
  void flutterError(FlutterErrorDetails details) =>
      _runWithFirebaseRetry(() => FirebaseCrashlytics.instance.recordFlutterError(details));

  @override
  void error(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) {
    _runWithFirebaseRetry(() {
      final effectiveMessage = sanitizedMessage ?? message;
      FirebaseCrashlytics.instance.recordError(e ?? effectiveMessage, s, reason: effectiveMessage);
    });
  }

  @override
  void warning(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) => _log(message, sanitizedMessage);

  @override
  void info(String message, {Object? e, StackTrace? s, String? sanitizedMessage}) => _log(message, sanitizedMessage);

  void _log(String message, String? sanitizedMessage) {
    _runWithFirebaseRetry(() {
      final effectiveMessage = sanitizedMessage ?? message;
      FirebaseCrashlytics.instance.log(effectiveMessage);
    });
  }

  void _runWithFirebaseRetry(void Function() block) {
    if (!_isFirebaseInitialized) {
      // we want to be sure that all errors are reported so we'll retry until firebase is initialized
      unawaited(Future.delayed(const Duration(seconds: 1), () => _runWithFirebaseRetry(block)));
    } else {
      block();
    }
  }

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;
}
