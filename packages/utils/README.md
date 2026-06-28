<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/utils/docs/header.png" width="209" alt="Utopia Utils"/>

# utopia_utils

A small grab-bag of foundational Dart utilities used across the Utopia USS ecosystem. Provides Kotlin-style object scope extensions, a lightweight `Value`/`MutableValue` abstraction, and a `Retryable` error wrapper.

## Highlights

### Scope extensions on every object (`AnyExtensions`)

Kotlin-style chaining helpers available on any type:

```dart
final trimmed = rawInput
    .let((s) => s.trim())          // transform and return a new value
    .takeIf((s) => s.isNotEmpty);  // return null if condition fails

final user = User()
    ..also((u) => logger.log(u));  // side-effect, returns same object
```

Also includes `cast<T>()` and `tryCast<T>()` for safe type narrowing.

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

`ValueExtensions` adds `.get()` (useful as a tear-off) and `.call()` shorthand. `MutableValueExtensions` adds `.set()`, `.modify()`, and `.cast()`.

### Retryable

Attaches a retry callback to any existing object via an `Expando`, so error-handling code can call `Retryable.tryGet(error)?.retry()` without the original object implementing any interface.

```dart
// Wrap an error with a retry action
final retryable = Retryable.make(error, () => fetchData());

// Later, in error UI or middleware
Retryable.tryGet(caughtError)?.retry();
```
