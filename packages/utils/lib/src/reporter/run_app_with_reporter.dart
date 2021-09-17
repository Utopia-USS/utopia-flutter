import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_utils/src/reporter/reporter.dart';

void runAppWithReporter(Reporter reporter, Widget app) {
  // handle flutter framework errors
  FlutterError.onError = reporter.flutterError;

  // handle uncaught dart errors (not supported on Web)
  if (!kIsWeb) {
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      reporter.error('Uncaught error', e: errorAndStacktrace.first, s: errorAndStacktrace.last);
    }).sendPort);
  }

  // run app and handle uncaught failed futures
  runZonedGuarded(
    () => runApp(app),
    (e, s) => reporter.error('Uncaught error', e: e, s: s),
  );
}
