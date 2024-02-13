import 'package:flutter/foundation.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract class ListenableValue<T> implements Value<T>, Listenable {}

abstract class ListenableMutableValue<T> implements MutableValue<T>, ListenableValue<T> {
  factory ListenableMutableValue(T value) => ListenableMutableValueImpl(value);
}

class ListenableMutableValueImpl<T> extends MutableValueImpl<T>
    with ChangeNotifier
    implements ListenableMutableValue<T> {
  ListenableMutableValueImpl(super.value);

  @override
  set value(T value) {
    if (value == super.value) return;
    super.value = value;
    notifyListeners();
  }
}
