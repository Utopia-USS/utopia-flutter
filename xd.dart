class AppRouteCall<A, R> {
  final A args;
  final void Function(R) pop;

  const AppRouteCall({required this.args, required this.pop});
}

typedef AppRouteBuilder<A, R> = Route<R> Function(AppRouteCall<A, R> call);

abstract class AppRouteAccessor<A, R> {
  const AppRouteAccessor();

  Future<R?> push(A args);

  Future<R?> call(A args) => push(args);
}

abstract class AppNamedRouteAccessor<A, R> extends AppRouteAccessor<A, R> {
  const AppNamedRouteAccessor();

  void popUntil();
}

class _AnonymousAccessorImpl<A, R> extends AppRouteAccessor<A, R> {
  final AppRouteBuilder<A, R> builder;
  final NavigatorState navigator;

  const _AnonymousAccessorImpl({required this.builder, required this.navigator});

  @override
  Future<R?> push(A args) => navigator.push(builder(AppRouteCall(args: args, pop: navigator.pop)));
}

class _NamedAccessorImpl<A, R> extends AppNamedRouteAccessor<A, R> {
  final String name;
  final AppRouteBuilder<A, R> builder;
  final NavigatorState Function() navigator;

  const _AccessorImpl({required this.name, required this.builder, required this.navigator});

  @override
  void popUntil() =>

  @override
  Future<R?> push(A args) {
    // TODO: implement push
    throw UnimplementedError();
  }
}

abstract class BaseAppNavigator {
  final GlobalKey<NavigatorState> _navigatorKey;

  const BaseAppNavigator(this._navigatorKey);

  AppRouteAccessor<A, R> route<A, R>(AppRouteBuilder<A, R> builder, {String? name}) {

  }
}

extension BaseAppNavigatorExtensions on BaseAppNavigator {
  AppRouteAccessor<A, R> screen<A, R, S>(S Function(AppRouteCall<A, R>) useState, Widget Function(S) view, {String? name}) =>
      route((call) => MaterialPageRoute(builder: (context) => HookBuilder(builder: (context) => view(useState(call)))));
}

mixin RouteA on BaseAppNavigator {
  late final a = route(name: "xd", (call) => MaterialPageRoute(builder: (context) => Text(call.args.toString())));
}

class AppNavigator = BaseAppNavigator with RouteA;