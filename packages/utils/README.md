<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/utils/docs/header.png" width="209" alt="Utopia Utils"/>

# utopia_utils

A small grab-bag of foundational Dart utilities used across the Utopia USS ecosystem. Provides Kotlin-style object scope extensions, a lightweight [`Value`][Value]/[`MutableValue`][MutableValue] abstraction, and a [`Retryable`][Retryable] error wrapper.

## Highlights

### Scope extensions on every object ([`AnyExtensions`][AnyExtensions])

Kotlin-style chaining helpers available on any type:

```dart
final trimmed = rawInput
    .let((s) => s.trim())          // transform and return a new value
    .takeIf((s) => s.isNotEmpty);  // return null if condition fails

final user = User()
    ..also((u) => logger.log(u));  // side-effect, returns same object
```

Also includes [`cast<T>()`][cast] and [`tryCast<T>()`][tryCast] for safe type narrowing.

### Value / MutableValue

A lightweight alternative to `ValueNotifier` (without the listener overhead) for passing readable or read-write values by reference.

```dart
// Read-only wrapper
final Value<String> label = Value('hello');

// Simple mutable box
final MutableValue<int> counter = MutableValue(0);
counter.modify((n) => n + 1);  // increment in-place
counter.toggle();               // on MutableValue<bool>

// Computed / delegate variants for derived values
final derived = MutableValue<String>.computed(
  () => counter.value.toString(),
  (v) => counter.value = int.parse(v),
);
```

[`ValueExtensions`][ValueExtensions] adds `.get()` (useful as a tear-off) and `.call()` shorthand. [`MutableValueExtensions`][MutableValueExtensions] adds `.set()`, `.modify()`, and `.cast()`.

### Retryable

[`Retryable`][Retryable] attaches a retry callback to any existing object via an `Expando`, so error-handling code can call [`Retryable.tryGet(error)?.retry()`][tryGet] without the original object implementing any interface.

```dart
// Wrap an error with a retry action
final retryable = Retryable.make(error, () => fetchData());

// Later, in error UI or middleware
Retryable.tryGet(caughtError)?.retry();
```

[AnyExtensions]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/AnyExtensions.html
[cast]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/AnyExtensions/cast.html
[tryCast]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/AnyExtensions/tryCast.html
[Value]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/Value-class.html
[MutableValue]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/MutableValue-class.html
[ValueExtensions]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/ValueExtensions.html
[MutableValueExtensions]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/MutableValueExtensions.html
[Retryable]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/Retryable-class.html
[tryGet]: https://pub.dev/documentation/utopia_utils/latest/utopia_utils/Retryable/tryGet.html
