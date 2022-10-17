import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

export 'src/reporter/crashlytics_reporter.dart';

class UtopiaFirebaseCrashlytics {
  static bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  static Future<void> setup() async {
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
  }

  static void ensure(void Function(FirebaseCrashlytics crashlytics) block) {
    if (!_isFirebaseInitialized) {
      unawaited(Future.delayed(const Duration(seconds: 1), () => ensure(block)));
    } else {
      block(FirebaseCrashlytics.instance);
    }
  }
}
