import 'mutable_injector.dart';

abstract class Injector {
  T get<T>({Object? key});

  bool exists<T>({Object? key});

  static Injector build(void Function(InjectorRegister register) block, {Injector? parent}) {
    final injector = MutableInjector(parent);
    block(injector.register);
    return injector;
  }
}

extension InjectorX on Injector {
  T call<T>({Object? key}) => get(key: key);
}
