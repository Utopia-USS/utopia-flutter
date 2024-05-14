import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract class Notifiable {
  void notify();
}

abstract class NotifiableValue<T> implements Value<T>, Notifiable {}

abstract class ListenableNotifiable implements Listenable, Notifiable {}

abstract class ListenableNotifiableValue<T> implements ListenableValue<T>, NotifiableValue<T>, ListenableNotifiable {
  factory ListenableNotifiableValue(T value) = ListenableNotifiableValueImpl;
}

class ListenableNotifiableValueImpl<T> extends ValueImpl<T>
    with ChangeNotifier
    implements ListenableNotifiableValue<T> {
  ListenableNotifiableValueImpl(super.value);

  @override
  void notify() => notifyListeners();
}

extension NotifiableExtension on Notifiable {
  // ignore: avoid_positional_boolean_parameters
  void notifyIf(bool condition) {
    if (condition) notify();
  }
}

extension NotifiableValueExtension<T> on NotifiableValue<T> {
  NotifiableValue<T2> map<T2>(T2 Function(T it) block) => _MappedNotifiableValue(this, block);

  MutableValue<T2> mapToMutable<T2>(T2 Function(T it) get, void Function(T it, T2 value) set) =>
    MutableValue.computed(() => get(value), (value) => mutate((it) => set(it, value)));

  R mutate<R>(R Function(T it) block) {
    final result = block(value);
    notify();
    return result;
  }

  void maybeMutate(bool Function(T it) block) => notifyIf(block(value));
}

class _MappedNotifiableValue<T, T2> implements NotifiableValue<T2> {
  final NotifiableValue<T> delegate;
  final T2 Function(T) block;

  const _MappedNotifiableValue(this.delegate, this.block);

  @override
  void notify() => delegate.notify();

  @override
  T2 get value => block(delegate.value);
}
