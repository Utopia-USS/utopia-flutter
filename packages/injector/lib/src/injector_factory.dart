import 'package:meta/meta.dart';

import 'injector.dart';

typedef InjectorDependencyBuilder<T> = T Function(Injector);

@optionalTypeArgs
abstract class InjectorFactory<T> {
  T call(Injector injector);

  const factory InjectorFactory.instance(T instance) = _InstanceFactory;

  const factory InjectorFactory.provider(InjectorDependencyBuilder<T> builder) = _ProviderFactory;

  factory InjectorFactory.singleton(InjectorDependencyBuilder<T> builder) = _SingletonFactory;
}

class _InstanceFactory<T> implements InjectorFactory<T> {
  final T instance;

  const _InstanceFactory(this.instance);

  @override
  T call(Injector injector) => instance;
}

/// This Factory does lazy instantiation of [T] and
/// always returns a new instance built by the [builder].
class _ProviderFactory<T> implements InjectorFactory<T> {
  final InjectorDependencyBuilder<T> builder;

  const _ProviderFactory(this.builder);

  @override
  T call(Injector injector) => builder(injector);
}

/// This Factory does lazy instantiation of [T] and
/// returns the same instance when accessing [call].
class _SingletonFactory<T> implements InjectorFactory<T> {
  InjectorDependencyBuilder<T> builder;

  T? _value;

  _SingletonFactory(this.builder);

  @override
  T call(Injector injector) => _value ??= builder(injector);
}
