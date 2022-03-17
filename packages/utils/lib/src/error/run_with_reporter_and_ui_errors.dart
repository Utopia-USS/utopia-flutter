import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/src/error/global_error_handler.dart';
import 'package:utopia_utils/src/error/reporter_global_error_handler.dart';
import 'package:utopia_utils/src/error/retryable.dart';
import 'package:utopia_utils/src/reporter/reporter.dart';
import 'package:utopia_utils/utopia_utils_extensions.dart';

class UiGlobalError {
  final Object? error;

  const UiGlobalError([this.error]);

  void Function()? get retry => error?.let(Retryable.tryGet)?.retry;

  bool get canRetry => retry != null;
}

void runWithReporterAndUiErrors(Reporter reporter, void Function(Stream<UiGlobalError> uiErrors) block) {
  final controller = StreamController<UiGlobalError>();
  final handler = GlobalErrorHandler.combine([ReporterGlobalErrorHandler(reporter), _UiGlobalErrorHandler(controller)]);
  runWithErrorHandler(handler, () => block(controller.stream));
}

class _UiGlobalErrorHandler implements GlobalErrorHandler {
  final StreamController<UiGlobalError> controller;

  const _UiGlobalErrorHandler(this.controller);

  @override
  void onOtherError(Object error, StackTrace stackTrace) =>
      controller.add(UiGlobalError(error));

  @override
  void onFlutterError(FlutterErrorDetails details) =>
      controller.add(UiGlobalError(details.exception));

  @override
  void onSerializedError(String error, StackTrace? stackTrace) => controller.add(const UiGlobalError());
}
