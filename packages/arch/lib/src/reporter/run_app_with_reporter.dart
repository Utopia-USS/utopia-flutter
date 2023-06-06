import 'package:flutter/widgets.dart';
import 'package:utopia_arch/src/error/run_with_reporter_and_ui_errors.dart';
import 'package:utopia_utils/utopia_utils.dart';

@Deprecated("Replace with runWithReporterAndUiErrors")
void runAppWithReporter(Reporter reporter, Widget app) => runWithReporterAndUiErrors(reporter, (_) => runApp(app));
