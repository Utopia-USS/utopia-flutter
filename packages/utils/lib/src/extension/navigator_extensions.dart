import 'package:flutter/cupertino.dart';

extension NavigatorExtensions on NavigatorState {
  void flow(List<Function Function() Function(Function Function() next)> steps) =>
      steps.reversed.fold<Function Function()>(() => () {}, (acc, step) => step(acc))();

  Future<void> pushNamedAndReset(String route, {Object? arguments}) async =>
      pushNamedAndRemoveUntil(route, (_) => false, arguments: arguments);
}
