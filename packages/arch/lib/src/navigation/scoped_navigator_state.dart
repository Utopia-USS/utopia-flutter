import 'package:flutter/cupertino.dart';

@Deprecated("Use context.navigator or navigatorKey passing")
class ScopedNavigatorState {
  final GlobalKey<NavigatorState> navigatorKey;

  const ScopedNavigatorState({required this.navigatorKey});

  NavigatorState get navigator => navigatorKey.currentState!;
}
