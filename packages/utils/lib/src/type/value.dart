import 'package:flutter/foundation.dart';

abstract class Value<T> {
  T get value;

  // constructors
  const factory Value(T value) = _ValueImpl;

  const factory Value.delegate(T Function() get) = _DelegateValueImpl;

  factory Value.ofValueListenable(ValueListenable<T> listenable) => Value.delegate(() => listenable.value);
}

/// Simpler alternative to [ValueNotifier].
///
/// To convert a [ValueNotifier] to [MutableValue] use the `.asMutableValue()` extension.
abstract class MutableValue<T> implements Value<T> {
  @override
  T get value;

  set value(T value);

  // constructors
  factory MutableValue(T initialValue) = _MutableValueImpl;
  
  const factory MutableValue.delegate(T Function() get, void Function(T) set) = _DelegateMutableValueImpl;

  factory MutableValue.late() = _LateMutableValueImpl;

  factory MutableValue.ofValueNotifier(ValueNotifier<T> notifier) =>
      MutableValue.delegate(() => notifier.value, (value) => notifier.value = value);
}

class _ValueImpl<T> implements Value<T> {
  @override
  final T value;

  const _ValueImpl(this.value);
}

class _MutableValueImpl<T> implements MutableValue<T> {
  @override
  T value;

  _MutableValueImpl(this.value);
}

class _LateMutableValueImpl<T> implements MutableValue<T> {
  @override
  late T value;
}

class _DelegateValueImpl<T> implements Value<T> {
  final T Function() _get;

  const _DelegateValueImpl(this._get);

  @override
  T get value => _get();
}

class _DelegateMutableValueImpl<T> implements MutableValue<T> {
  final T Function() _get;
  final void Function(T) _set;

  const _DelegateMutableValueImpl(this._get, this._set);

  @override
  T get value => _get();

  @override
  set value(T value) => _set(value);
}
