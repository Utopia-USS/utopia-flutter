import '../injector.dart';

/// Gets registered at the injector and then gets called by the injector to
/// instantiate the dependency and all of its dependencies.
///
///
/// Example:
/// ```dart
/// final myInjector = Injector();
///
/// myInjector.registerDependency<Car>(() {
///     var engine = myInjector.getDependency<Engine>();
///     return CarImpl(engine: engine);
/// });
/// ```
typedef DependencyBuilder<T> = T Function(Injector injector);

abstract class Factory<T> {
  T call(Injector injector);

  static Factory<T> instance<T>(T instance) => _InstanceFactory(instance);

  static Factory<T> provider<T>(DependencyBuilder<T> builder) => _ProviderFactory(builder);

  static Factory<T> singleton<T>(DependencyBuilder<T> builder) => _SingletonFactory(builder);
}

class _InstanceFactory<T> implements Factory<T> {
  final T instance;

  const _InstanceFactory(this.instance);

  @override
  T call(Injector injector) => instance;
}

/// This Factory does lazy instantiation of [T] and
/// always returns a new instance built by the [builder].
class _ProviderFactory<T> implements Factory<T> {
  DependencyBuilder<T> builder;

  _ProviderFactory(this.builder);

  @override
  T call(Injector injector) => builder(injector);
}

/// This Factory does lazy instantiation of [T] and
/// returns the same instance when accessing [call].
class _SingletonFactory<T> implements Factory<T> {
  DependencyBuilder<T> builder;

  T? _value;

  _SingletonFactory(this.builder);

  @override
  T call(Injector injector) => _value ??= builder(injector);
}
