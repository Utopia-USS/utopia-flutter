import 'package:meta/meta.dart';

import 'mutable_injector.dart';

abstract class Injector {
  dynamic getRaw(Type type, {Object? key});

  T get<T>({Object? key}) => getRaw(T, key: key) as T;

  bool existsRaw(Type type, {Object? key});

  bool exists<T>({Object? key}) => existsRaw(T, key: key);

  // Do not move to an extension - importing doesn't work nicely
  T call<T>({Object? key}) => get(key: key);

  static Injector build(void Function(InjectorRegister register) block, {Injector? parent}) {
    final injector = MutableInjector(parent);
    block(injector.register);
    return injector;
  }

  static Future<Injector> buildAsync(Future<void> Function(InjectorRegister register) block, {Injector? parent}) async {
    final injector = MutableInjector(parent);
    await block(injector.register);
    return injector;
  }
}
