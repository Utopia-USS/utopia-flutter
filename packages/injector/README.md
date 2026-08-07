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

## [`InjectorRegister`][InjectorRegister] methods

| Method | Behaviour |
|---|---|
| [`singleton<T>(block)`][singleton] | Lazy singleton - `block` is called once, same instance returned every time. Calling `register<T>(block)` is equivalent. |
| [`provider<T>(block)`][provider] | New instance on every resolution. |
| [`instance<T>(value)`][instance] | Registers a pre-built instance. |
| [`noarg<T>(block)`][noarg] | Singleton where the builder takes no `Injector` argument. |
| [`alias<T, T2>()`][alias] | Makes `T` resolve to whatever `T2` resolves to. |
| [`factory<T>(factory)`][factory] | Registers a custom [`InjectorFactory<T>`][InjectorFactory]. |
| [`raw(type, factory)`][raw] | Type-erased registration for dynamic use-cases. |

All methods accept an optional `key` parameter to distinguish multiple registrations of the same type.

Use [`register.override.<method>`][override] to replace an existing registration without throwing.

## [`Injector`][Injector] API

- [`get<T>({Object? key})`][get] - resolve a dependency by type (and optional key).
- [`call<T>({Object? key})`][call] - callable shorthand for `get<T>()`.
- [`exists<T>({Object? key})`][exists] - check whether a type is registered.
- [`Injector.build(block, {Injector? parent})`][build] - build a synchronous injector; pass `parent` for scoped child containers.
- [`Injector.buildAsync(block, {Injector? parent})`][buildAsync] - async variant.

Resolving an unregistered type throws `NotDefinedException`. Circular dependencies throw `CircularDependencyException`. Duplicate registrations (without `override`) throw `AlreadyDefinedException`.

[Injector]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/Injector-class.html
[InjectorRegister]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister-class.html
[InjectorFactory]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorFactory-class.html
[singleton]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/singleton.html
[provider]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/provider.html
[instance]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/instance.html
[noarg]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/noarg.html
[alias]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/alias.html
[factory]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/factory.html
[raw]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/raw.html
[override]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/InjectorRegister/override.html
[get]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/Injector/get.html
[call]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/Injector/call.html
[exists]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/Injector/exists.html
[build]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/Injector/build.html
[buildAsync]: https://pub.dev/documentation/utopia_injector/latest/utopia_injector/Injector/buildAsync.html
