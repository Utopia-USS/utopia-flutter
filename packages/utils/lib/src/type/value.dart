abstract class Value<T> {
  T get value;

  const factory Value(T value) = ValueImpl;

  const factory Value.computed(T Function() get) = ComputedValue;

  const factory Value.delegate(Value<T> delegate) = DelegateValue;
}

/// Simpler alternative to `ValueNotifier`.
///
/// To convert a `ValueNotifier` to [MutableValue] use the `.asMutableValue()` extension.
abstract class MutableValue<T> implements Value<T> {
  // ignore: avoid_setters_without_getters
  set value(T value);

  factory MutableValue(T initialValue) = MutableValueImpl;
  
  const factory MutableValue.property(T value, void Function(T) set) = PropertyMutableValue;

  const factory MutableValue.computed(T Function() get, void Function(T) set) = ComputedMutableValue;

  const factory MutableValue.delegate(MutableValue<T> value) = DelegateMutableValue;

  factory MutableValue.late() = LateMutableValue;
}

class ValueImpl<T> implements Value<T> {
  @override
  final T value;

  const ValueImpl(this.value);
}

class MutableValueImpl<T> implements MutableValue<T> {
  @override
  T value;

  MutableValueImpl(this.value);
}

class PropertyMutableValue<T> extends ValueImpl<T> implements MutableValue<T> {
  final void Function(T) _set;

  const PropertyMutableValue(super.value, this._set);

  @override
  set value(T value) => _set(value);
}

class LateMutableValue<T> implements MutableValue<T> {
  @override
  late T value;
}

base class ComputedValue<T> implements Value<T> {
  final T Function() _get;

  const ComputedValue(this._get);

  @override
  T get value => _get();
}

base class DelegateValue<T> implements Value<T> {
  final Value<T> _delegate;

  const DelegateValue(this._delegate);

  @override
  T get value => _delegate.value;
}

base class ComputedMutableValue<T> implements MutableValue<T> {
  final T Function() _get;
  final void Function(T) _set;

  const ComputedMutableValue(this._get, this._set);

  @override
  T get value => _get();

  @override
  set value(T value) => _set(value);
}

base class DelegateMutableValue<T> implements MutableValue<T> {
  final MutableValue<T> _delegate;

  const DelegateMutableValue(this._delegate);

  @override
  T get value => _delegate.value;

  @override
  set value(T value) => _delegate.value = value;
}
