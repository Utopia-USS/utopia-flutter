import 'dart:async';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:utopia_utils/reporter/reporter.dart';

void runAppWithReporter(Reporter reporter, Widget app) {
  FlutterError.onError = reporter.flutterError;
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    reporter.error('Uncaught error', errorAndStacktrace.first, errorAndStacktrace.last);
  }).sendPort);

  runZonedGuarded(
    () => runApp(app),
    (e, s) => reporter.error('Uncaught error', e, s),
  );
}
