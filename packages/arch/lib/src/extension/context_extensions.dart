import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  NavigatorState get navigator => Navigator.of(this);
  T routeArgs<T>() => ModalRoute.of(this)!.settings.arguments as T;
}
