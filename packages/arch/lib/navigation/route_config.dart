import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_utils/extension/extensions.dart';

enum RouteConfigOrientation { portrait, landscape }

class RouteConfig<T> {
  final Route<T> Function(RouteSettings, Widget Function()) routeBuilder;
  final Widget Function() contentBuilder;
  final RouteConfigOrientation? orientation;

  const RouteConfig({required this.routeBuilder, required this.contentBuilder, this.orientation});

  factory RouteConfig.material(
    Widget Function() builder, {
    RouteConfigOrientation? orientation,
  }) {
    return RouteConfig(
      routeBuilder: (settings, contentBuilder) => MaterialPageRoute<T>(
        builder: (_) => contentBuilder(),
        settings: settings,
      ),
      contentBuilder: builder,
      orientation: orientation,
    );
  }

  static Route generateInitialRoute(Map<String, RouteConfig> routes, String name) =>
      generateRoute(routes, RouteSettings(name: name));

  static Route generateRoute(Map<String, RouteConfig> routes, RouteSettings settings) {
    final config = routes[settings.name]!;
    return config.routeBuilder(settings, config.contentBuilder);
  }

  static NavigatorObserver createNavigationObserver(Map<String, RouteConfig> routes) =>
      _OrientationNavigatorObserver(routes);

  static final SystemUiOverlayStyle lightTop = SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);
  static final SystemUiOverlayStyle darkTop = SystemUiOverlayStyle.light
      .copyWith(statusBarColor: Colors.transparent, systemNavigationBarIconBrightness: Brightness.dark);
}

class _OrientationNavigatorObserver extends NavigatorObserver {
  static const _orientationMap = <RouteConfigOrientation?, List<DeviceOrientation>>{
    null: DeviceOrientation.values,
    RouteConfigOrientation.portrait: [DeviceOrientation.portraitUp],
    RouteConfigOrientation.landscape: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  };

  final Map<String, RouteConfig> _routes;

  _OrientationNavigatorObserver(this._routes) : super();

  @override
  void didPop(Route route, Route? previousRoute) {
    previousRoute?.settings.name?.let((it) => _routes[it])?.let((it) => _setSystemChrome(it.orientation));
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _routes[route.settings.name]?.let((it) => _setSystemChrome(it.orientation));
  }

  void _setSystemChrome(RouteConfigOrientation? orientation) {
    SystemChrome.setPreferredOrientations(_orientationMap[orientation]!);
  }
}
