<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/injector/docs/header.png" width="237" alt="Utopia Injector"/>

# utopia_injector

A lightweight dependency-injection container for Dart and Flutter. Register services once - as singletons, transient providers, or plain instances - then resolve them by type anywhere in your app. Supports optional string/object keys for disambiguating same-type registrations, scoped child injectors via a parent chain, and async setup.

## Usage

```dart
// Build an injector
final injector = Injector.build((register) {
  // Singleton: created once on first use
  register.singleton<ApiClient>((i) => ApiClient(baseUrl: 'https://api.example.com'));

  // Provider: new instance on every get<>()
  register.provider<UserRepository>((i) => UserRepositoryImpl(i<ApiClient>()));

  // Instance: a pre-existing object
  register.instance<Logger>(MyLogger());
});

// Resolve by type
final repo = injector.get<UserRepository>();

// Callable shorthand (same as get<>)
final client = injector<ApiClient>();
```

For async setup (e.g. reading config before building):

```dart
final injector = await Injector.buildAsync((register) async {
  final config = await loadConfig();
  register.instance<AppConfig>(config);
});
```

## `InjectorRegister` methods

| Method | Behaviour |
|---|---|
| `singleton<T>(block)` | Lazy singleton - `block` is called once, same instance returned every time. Calling `register<T>(block)` is equivalent. |
| `provider<T>(block)` | New instance on every resolution. |
| `instance<T>(value)` | Registers a pre-built instance. |
| `noarg<T>(block)` | Singleton where the builder takes no `Injector` argument. |
| `alias<T, T2>()` | Makes `T` resolve to whatever `T2` resolves to. |
| `factory<T>(factory)` | Registers a custom `InjectorFactory<T>`. |
| `raw(type, factory)` | Type-erased registration for dynamic use-cases. |

All methods accept an optional `key` parameter to distinguish multiple registrations of the same type.

Use `register.override.<method>` to replace an existing registration without throwing.

## `Injector` API

- `get<T>({Object? key})` - resolve a dependency by type (and optional key).
- `call<T>({Object? key})` - callable shorthand for `get<T>()`.
- `exists<T>({Object? key})` - check whether a type is registered.
- `Injector.build(block, {Injector? parent})` - build a synchronous injector; pass `parent` for scoped child containers.
- `Injector.buildAsync(block, {Injector? parent})` - async variant.

Resolving an unregistered type throws `NotDefinedException`. Circular dependencies throw `CircularDependencyException`. Duplicate registrations (without `override`) throw `AlreadyDefinedException`.
