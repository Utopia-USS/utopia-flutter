import 'package:flutter/foundation.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract class ListenableValue<T> implements Value<T>, Listenable {
  const factory ListenableValue(T value) = ListenableValueImpl;
}

abstract class ListenableMutableValue<T> implements MutableValue<T>, ListenableValue<T> {
  factory ListenableMutableValue(T value) = ListenableMutableValueImpl;
}

class ListenableValueImpl<T> extends ValueImpl<T> with NeverTriggeringListenable implements ListenableValue<T> {
  const ListenableValueImpl(super.value);
}

class ListenableMutableValueImpl<T> extends MutableValueImpl<T>
    with ChangeNotifier
    implements ListenableMutableValue<T> {
  final void Function()? onDisposed;

  ListenableMutableValueImpl(super.value, {this.onDisposed});

  @override
  set value(T value) {
    if (value == super.value) return;
    super.value = value;
    notifyListeners();
  }

  @override
  void dispose() {
    onDisposed?.call();
    super.dispose();
  }
}

/// Implementation of a [Listenable] that never triggers any listeners,
///
/// Since the listeners will never be called, they are not stored.
mixin NeverTriggeringListenable implements Listenable {
  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
