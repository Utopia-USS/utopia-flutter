import 'package:flutter/cupertino.dart';

extension NavigatorExtensions on NavigatorState {
  void flow(List<Function Function(Function next)> steps) =>
      steps.reversed.fold<Function>(() {}, (acc, step) => step(acc))();

  void pushNamedAndReset(String route, {Object? arguments}) =>
      pushNamedAndRemoveUntil(route, (_) => false, arguments: arguments);
}
