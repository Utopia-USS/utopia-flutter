import 'package:utopia_utils/src/type/value.dart';

extension ValueExtensions<T> on Value<T> {
  /// For easy tear-offs.
  T get() => value;

  /// For short-hand access.
  T call() => value;
}

extension MutableValueExtensions<T> on MutableValue<T> {
  /// For easy tear-offs.
  // ignore: use_setters_to_change_properties
  void set(T value) => this.value = value;

  void modify(T Function(T value) block) => value = block(value);
}

extension NotNullMutableValueExtensions<T extends Object> on MutableValue<T> {
  T call([T? value]) {
    if(value != null) this.value = value;
    return this.value;
  }
}

extension BoolMutableValueExtensions on MutableValue<bool> {
  void toggle() => value = !value;
}
