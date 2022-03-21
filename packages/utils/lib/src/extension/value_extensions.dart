import 'package:utopia_utils/src/type/value.dart';

extension ValueExtensions<T> on Value<T> {
  T call() => value;
}

extension MutableValueExtensions<T> on MutableValue<T> {
  void modify(T Function(T value) block) => value = block(value);
}

extension NotNullMutableValueExtensions<T extends Object> on MutableValue<T> {
  T call([T? value]) {
    if(value != null) this.value = value;
    return this.value;
  }
}
