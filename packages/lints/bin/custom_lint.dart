import 'dart:isolate';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:utopia_lints/utopia_lints.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, UtopiaLints());
}