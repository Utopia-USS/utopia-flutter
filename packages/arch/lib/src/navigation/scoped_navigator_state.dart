import 'package:flutter/cupertino.dart';

@Deprecated("Use context.navigator or navigatorKey passing")
class ScopedNavigatorState {
  final GlobalKey<NavigatorState> navigatorKey;

  @Deprecated("Use context.navigator or navigatorKey passing")
  const ScopedNavigatorState({required this.navigatorKey});

  NavigatorState get navigator => navigatorKey.currentState!;
}
