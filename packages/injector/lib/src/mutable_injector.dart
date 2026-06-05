import 'exception/already_defined_exception.dart';
import 'exception/circular_dependency_exception.dart';
import 'exception/not_defined_exception.dart';
import 'injector.dart';
import 'injector_factory.dart';

class MutableInjector extends Injector {
  MutableInjector([this._parent]);

  final Injector? _parent;

  /// Stores the all registered [InjectorFactory].
  final _factoryMap = <String, InjectorFactory<dynamic>>{};

  /// Registers a dependency that will be created with the provided [InjectorFactory].
  /// See [InjectorFactory.provider] or [InjectorFactory.singleton].
  /// You can also create your custom factory by implementing [InjectorFactory].
  ///
  /// Overrides dependencies with the same signature when [override] is true.
  /// Uses [key] to differentiate between dependencies that have the
  /// same type.
  ///
  /// The signature of a dependency consists of [type]
  /// and the optional [key].
  ///
  /// ```dart
  /// abstract class UserService {
  ///   void login(String username, String password);
  /// }
  ///
  /// class UserServiceImpl implements UserService {
  ///   void login(String username, String password) {
  ///     .....
  ///     .....
  ///   }
  /// }
  ///
  /// injector.register(Factory.singleton(() => UserServiceImpl()));
  /// ```
  /// Then getting the registered dependency:
  /// ```dart
  /// injector.get<UserService>();
  /// ```
  void _register(Type type, InjectorFactory factory, {Object? key, bool override = false}) {
    _checkValidation(type);
    final identity = _getIdentity(type, key);
    if (!override) _checkForDuplicates(type, identity);
    _factoryMap[identity] = factory;
  }

  InjectorRegister get register => InjectorRegister._(this);

  /// Whenever a factory is called to get a dependency
  /// the identifier of that factory is saved to this set and
  /// is removed when the instance is successfully created.
  ///
  /// A circular dependency is detected when the factory id was not removed
  /// meaning that the instance was not created
  /// but the same factory was called more than once
  final _factoryCallIds = <int>{};

  /// Returns the registered dependencies with the signature of [type] and
  /// the optional [key].
  ///
  /// Throws [NotDefinedException] when the requested dependency has not been
  /// registered yet.
  ///
  /// Throws [CircularDependencyException] when the injector detected a circular
  /// dependency setup.
  @override
  dynamic getRaw(Type type, {Object? key}) {
    _checkValidation(type);

    final identity = _getIdentity(type, key);

    final factory = _factoryMap[identity];

    if (factory == null) {
      if (_parent != null && _parent.existsRaw(type, key: key)) {
        return _parent.getRaw(type, key: key);
      }
      throw NotDefinedException(type: type.toString());
    }

    final factoryId = factory.hashCode;

    final unique = _factoryCallIds.add(factoryId);
    if (!unique) {
      throw CircularDependencyException(type: type.toString());
    }

    try {
      final instance = factory.call(this);
      _factoryCallIds.remove(factoryId);
      return instance;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // In case something went wrong, we have to clear the called factory list
      // because this will trigger a [CircularDependencyException] the next time
      // this factory is called again.
      _factoryCallIds.clear();
      rethrow;
    }
  }

  /// Checks if the dependency with the signature of [type] and [key] exists.
  @override
  bool existsRaw(Type type, {Object? key}) {
    _checkValidation(type);

    final dependencyKey = _getIdentity(type, key);
    return _factoryMap.containsKey(dependencyKey) || (_parent?.existsRaw(type, key: key) ?? false);
  }

  /// Removes the dependency with the signature of [T] and [key].
  void removeByKey<T>({Object? key}) {
    _checkValidation(T);

    final dependencyKey = _getIdentity(T, key);
    _factoryMap.remove(dependencyKey);
  }

  /// Removes all registered dependencies.
  void clearAll() {
    _factoryCallIds.clear();
    _factoryMap.clear();
  }

  /// Checks if [type] is actually set.
  void _checkValidation(Type type) {
    if (type == dynamic) {
      throw Exception(
        'No type specified !\nCan not register dependencies for type "$type"',
      );
    }
  }

  void _checkForDuplicates(Type type, String identity) {
    if (_factoryMap.containsKey(identity)) {
      throw AlreadyDefinedException(type: type.toString());
    }
  }

  String _getIdentity(Type type, Object? key) => "$key${type.hashCode}";
}

class InjectorRegister {
  final MutableInjector _injector;
  final bool _override;

  const InjectorRegister._(this._injector, [this._override = false]);

  InjectorRegister get override => InjectorRegister._(_injector, true);

  void call<T>(T Function(Injector) block, {Object? key}) => singleton(block, key: key);

  void singleton<T>(T Function(Injector) block, {Object? key}) => factory(InjectorFactory.singleton(block), key: key);

  void provider<T>(T Function(Injector) block, {Object? key}) => factory(InjectorFactory.provider(block), key: key);

  void instance<T>(T instance, {Object? key}) => factory(InjectorFactory.instance(instance), key: key);

  void noarg<T>(T Function() block, {Object? key}) => singleton((_) => block(), key: key);

  void alias<T, T2 extends T>({Object? key}) => provider<T>((injector) => injector<T2>(key: key), key: key);

  void factory<T>(InjectorFactory<T> factory, {Object? key}) => raw(T, factory, key: key);

  void raw(Type type, InjectorFactory factory, {Object? key}) =>
      _injector._register(type, factory, key: key, override: _override);
}
