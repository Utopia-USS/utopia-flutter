import 'package:flutter/cupertino.dart';


class ScopedNavigatorState {
  final GlobalKey<NavigatorState> navigatorKey;

  const ScopedNavigatorState({required this.navigatorKey});

  NavigatorState get navigator => navigatorKey.currentState!;
}
