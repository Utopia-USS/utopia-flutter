<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/validation/docs/header.png" width="265" alt="Utopia Validation"/>

# utopia_validation

Lightweight validation primitives for Flutter. Defines `Validator<T>` and `AsyncValidator<T>` function types that produce a context-aware error string (or `null` on success), plus a `Validatable<T>` interface for objects that carry their own validation state. Pairs naturally with `useFieldState` from `utopia_hooks`.

## Core types

- `Validator<T>` - a function `(T value) -> ValidatorResult?`
- `AsyncValidator<T>` - same, but `FutureOr`
- `ValidatorResult` - `String Function(BuildContext)`, so error messages can be localised
- `Validatable<T>` - interface combining `Value<T>` and `HasErrorMessage`; exposes `validate` / `validateAsync` helpers that run a validator and store the result
- `Validators` - static factory methods for common validators

## Validators

```dart
// Fail when a String is empty
final required = Validators.notEmpty(onEmpty: (ctx) => 'Required');

// Fail when a condition holds
final noSpaces = Validators.conditional(
  (s) => s.contains(' '),
  onFalse: (ctx) => 'No spaces allowed',
);

// Fail when values differ
final mustMatch = Validators.equals(
  expected,
  onNotEqual: (ctx) => 'Values do not match',
);

// Run multiple validators in order, returning the first failure
final combined = Validators.combine([required, noSpaces]);

// Async variant
final asyncCombined = Validators.combineAsync([checkLocal, checkRemote]);
```
