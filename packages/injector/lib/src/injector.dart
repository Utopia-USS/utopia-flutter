import 'mutable_injector.dart';

abstract class Injector {
  T get<T>({Object? key});

  bool exists<T>({Object? key});

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
