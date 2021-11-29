import 'package:flutter_hooks/flutter_hooks.dart';

abstract class ValueWrapper<T> {
  abstract final T value;

  T Function() get getValue => () => value;

  T call() => value;
}

class _ValueWrapperImpl<T> extends ValueWrapper<T> {
  T value;

  _ValueWrapperImpl(this.value);
}

ValueWrapper<T> useValueWrapper<T>(T value) {
  final wrapper = useMemoized(() => _ValueWrapperImpl(value));
  wrapper.value = value;
  return wrapper;
}
