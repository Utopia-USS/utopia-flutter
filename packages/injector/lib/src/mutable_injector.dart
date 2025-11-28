import 'exception/already_defined_exception.dart';
import 'exception/circular_dependency_exception.dart';
import 'exception/not_defined_exception.dart';
import 'factory/factory.dart';
import 'injector.dart';

class MutableInjector extends Injector {
  MutableInjector([this._parent]);

  final Injector? _parent;

  /// Stores the all registered [Factory].
  final _factoryMap = <String, Factory<dynamic>>{};

  /// Registers a dependency that will be created with the provided [Factory].
  /// See [Factory.provider] or [Factory.singleton].
  /// You can also create your custom factory by implementing [Factory].
  ///
  /// Overrides dependencies with the same signature when [override] is true.
  /// Uses [key] to differentiate between dependencies that have the
  /// same type.
  ///
  /// The signature of a dependency consists of [T]
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
  void _register<T>(Factory<T> factory, {Object? key}) {
    _checkValidation<T>();
    final identity = _getIdentity<T>(key);
    _checkForDuplicates<T>(identity);
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

  /// Returns the registered dependencies with the signature of [T] and
  /// the optional [key].
  ///
  /// Throws [NotDefinedException] when the requested dependency has not been
  /// registered yet.
  ///
  /// Throws [CircularDependencyException] when the injector detected a circular
  /// dependency setup.
  @override
  T get<T>({Object? key}) {
    _checkValidation<T>();

    final identity = _getIdentity<T>(key);

    final factory = _factoryMap[identity];

    if (factory == null) {
      if (_parent != null && _parent.exists<T>(key: key)) {
        return _parent.get(key: key);
      }
      throw NotDefinedException(type: T.toString());
    }

    final factoryId = factory.hashCode;

    final unique = _factoryCallIds.add(factoryId);
    if (!unique) {
      throw CircularDependencyException(type: T.toString());
    }

    try {
      final instance = factory.call(this) as T;
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

  /// Checks if the dependency with the signature of [T] and [key] exists.
  @override
  bool exists<T>({Object? key}) {
    _checkValidation<T>();

    final dependencyKey = _getIdentity<T>(key);
    return _factoryMap.containsKey(dependencyKey) || (_parent?.exists<T>(key: key) ?? false);
  }

  /// Removes the dependency with the signature of [T] and [key].
  void removeByKey<T>({Object? key}) {
    _checkValidation<T>();

    final dependencyKey = _getIdentity<T>(key);
    _factoryMap.remove(dependencyKey);
  }

  /// Removes all registered dependencies.
  void clearAll() {
    _factoryCallIds.clear();
    _factoryMap.clear();
  }

  /// Checks if [T] is actually set.
  void _checkValidation<T>() {
    final type = T.toString();

    if (T == dynamic) {
      throw Exception(
        'No type specified !\nCan not register dependencies for type "$type"',
      );
    }
  }

  void _checkForDuplicates<T>(String identity) {
    if (_factoryMap.containsKey(identity)) {
      throw AlreadyDefinedException(type: T.toString());
    }
  }

  String _getIdentity<T>(Object? key) => "$key${T.hashCode}";
}

class InjectorRegister {
  final MutableInjector _injector;

  const InjectorRegister._(this._injector);

  void singleton<T>(T Function(Injector) block, {Object? key}) =>
      _injector._register(Factory.singleton(block), key: key);

  void provider<T>(T Function(Injector) block, {Object? key}) => _injector._register(Factory.provider(block), key: key);

  void instance<T>(T instance, {Object? key}) => _injector._register(Factory.instance(instance), key: key);

  void noarg<T>(T Function() block, {Object? key}) => singleton((_) => block(), key: key);

  void call<T>(T Function(Injector) block, {Object? key}) => singleton(block, key: key);
}
