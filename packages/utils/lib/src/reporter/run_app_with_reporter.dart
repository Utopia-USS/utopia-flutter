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
    Isolate.current.addErrorListener(
      // ignore: avoid_types_on_closure_parameters
      RawReceivePort((List<dynamic> pair) async {
        reporter.error('Uncaught error', e: pair.first, s: pair.last as StackTrace?);
      }).sendPort,
    );
  }

  // run app and handle uncaught failed futures
  runZonedGuarded(
    () => runApp(app),
    (e, s) => reporter.error('Uncaught error', e: e, s: s),
  );
}
