import 'package:injector/injector.dart';

class InjectorRegister {
  final Injector _injector;
  final bool _override;

  const InjectorRegister._(this._injector, [this._override = false]);

  void call<T>(T Function(Injector) creator, {bool? override}) =>
      _injector.registerSingleton(override: override ?? _override, () => creator(_injector));

  void noarg<T>(T Function() creator, {bool? override}) =>
      _injector.registerSingleton(override: override ?? _override, creator);

  void instance<T>(T instance, {bool? override}) =>
      _injector.registerSingleton(override: override ?? _override, () => instance);

  // ignore: avoid_positional_boolean_parameters
  InjectorRegister override([bool override = true]) => InjectorRegister._(_injector, override);
}

Injector buildInjector(void Function(InjectorRegister register) block) {
  final injector = Injector();
  block(InjectorRegister._(injector));
  return injector;
}
