import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

extension ListenableValueX<T> on ListenableValue<T> {
  ValueListenable<T> asValueListenable() => _ListenableValueValueListenable(this);

  ListenableValue<T2> map<T2>(T2 Function(T it) mapper) => _MappedListenableValue(this, mapper);
}

extension ValueListenableX<T> on ValueListenable<T> {
  ListenableValue<T> asListenableValue() => _ValueListenableListenableValue(this);
}

extension ValueNotifierX<T> on ValueNotifier<T> {
  ListenableMutableValue<T> asListenableMutableValue() => _ValueNotifierListenableMutableValue(this);
}

class _ListenableValueValueListenable<T> implements ValueListenable<T> {
  final ListenableValue<T> _value;

  _ListenableValueValueListenable(this._value);

  @override
  void addListener(VoidCallback listener) => _value.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _value.removeListener(listener);

  @override
  T get value => _value.value;
}

class _ValueListenableListenableValue<T> implements ListenableValue<T> {
  final ValueListenable<T> _value;

  _ValueListenableListenableValue(this._value);

  @override
  void addListener(VoidCallback listener) => _value.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _value.removeListener(listener);

  @override
  T get value => _value.value;
}

class _ValueNotifierListenableMutableValue<T> implements ListenableMutableValue<T> {
  final ValueNotifier<T> _value;

  _ValueNotifierListenableMutableValue(this._value);

  @override
  void addListener(VoidCallback listener) => _value.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _value.removeListener(listener);

  @override
  T get value => _value.value;

  @override
  set value(T value) => _value.value = value;
}

mixin DelegateListenable implements Listenable {
  Listenable get delegate;

  @override
  void addListener(VoidCallback listener) => delegate.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => delegate.removeListener(listener);
}

class _MappedListenableValue<T, D> with DelegateListenable implements ListenableValue<T> {
  @override
  final ListenableValue<D> delegate;
  final T Function(D) mapper;

  _MappedListenableValue(this.delegate, this.mapper);

  @override
  T get value => mapper(delegate.value);
}
