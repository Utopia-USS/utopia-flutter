import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract class GlobalErrorHandler {
  void onFlutterError(FlutterErrorDetails details);

  void onOtherError(Object error, StackTrace stackTrace);

  void onSerializedError(String error, StackTrace? stackTrace);

  static GlobalErrorHandler combine(List<GlobalErrorHandler> handlers) => _CombinedGlobalErrorHandler(handlers);
}

void runWithErrorHandler(GlobalErrorHandler handler, void Function() block) {
  // handle flutter framework errors
  FlutterError.onError = handler.onFlutterError;

  // handle uncaught dart errors (not supported on Web)
  if (!kIsWeb) {
    Isolate.current.addErrorListener(
      // ignore: avoid_types_on_closure_parameters
      RawReceivePort((List<dynamic> pair) async {
        handler.onSerializedError(pair.first as String, (pair.last as String?)?.let(StackTrace.fromString));
      }).sendPort,
    );
  }

  // run app and handle uncaught failed futures
  runZonedGuarded(block, handler.onOtherError);
}

class _CombinedGlobalErrorHandler implements GlobalErrorHandler {
  final List<GlobalErrorHandler> handlers;

  const _CombinedGlobalErrorHandler(this.handlers);

  @override
  void onOtherError(Object error, StackTrace stackTrace) {
    for (final handler in handlers) {
      handler.onOtherError(error, stackTrace);
    }
  }

  @override
  void onFlutterError(FlutterErrorDetails details) {
    for (final handler in handlers) {
      handler.onFlutterError(details);
    }
  }

  @override
  void onSerializedError(String error, StackTrace? stackTrace) {
    for (final handler in handlers) {
      handler.onSerializedError(error, stackTrace);
    }
  }
}
