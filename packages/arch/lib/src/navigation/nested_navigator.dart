import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_arch/src/navigation/route_config.dart';

class NestedNavigator extends HookWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final NavigatorState parentNavigator;
  final Map<String, RouteConfig> routes;
  final String initialRoute;

  const NestedNavigator({
    super.key,
    required this.navigatorKey,
    required this.routes,
    required this.initialRoute,
    required this.parentNavigator,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        unawaited(navigatorKey.currentState?.maybePop());
        return false;
      },
      child: Navigator(
        observers: [
          useMemoized(() => HeroController(createRectTween: _createRectTween)),
          RouteConfig.createNavigationObserver(routes),
        ],
        key: navigatorKey,
        onGenerateInitialRoutes: (_, route) => [
          // dummy route to force back button on initial route
          if (parentNavigator.canPop()) MaterialPageRoute(builder: (_) => Container()),
          _generateRoute(RouteSettings(name: route)),
        ],
        onGenerateRoute: _generateRoute,
        initialRoute: initialRoute,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    // WARNING: will break if initial route is pushed on stack
    if (settings.name == initialRoute) {
      final config = routes[settings.name]!;
      return config.routeBuilder(
        settings,
        () => WillPopScope(
          onWillPop: () async {
            parentNavigator.pop();
            return false;
          },
          child: config.contentBuilder(),
        ),
      );
    } else {
      return RouteConfig.generateRoute(routes, settings);
    }
  }

  RectTween _createRectTween(Rect? begin, Rect? end) => MaterialRectArcTween(begin: begin, end: end);
}
