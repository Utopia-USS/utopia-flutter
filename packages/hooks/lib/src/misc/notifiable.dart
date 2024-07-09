import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

abstract class Notifiable {
  void notify();
}

abstract class NotifiableValue<T> implements Value<T>, Notifiable {
  const factory NotifiableValue(T value, void Function() notify) = NotifiableValueImpl;
}

abstract class ListenableNotifiable implements Listenable, Notifiable {}

abstract class ListenableNotifiableValue<T> implements ListenableValue<T>, NotifiableValue<T>, ListenableNotifiable {
  factory ListenableNotifiableValue(T value) = ListenableNotifiableValueImpl;
}

class NotifiableValueImpl<T> extends ValueImpl<T> implements NotifiableValue<T> {
  final void Function() _notify;

  const NotifiableValueImpl(super.value, this._notify);

  @override
  void notify() => _notify();
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

extension ListenableNotifiableValueExtension<T> on ListenableNotifiableValue<T> {
  ListenableNotifiableValue<T2> map<T2>(T2 Function(T it) block) => _MappedListenableNotifiableValue(this, block);
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

class _MappedListenableNotifiableValue<T, T2> with DelegateListenable implements ListenableNotifiableValue<T2> {
  @override
  final ListenableNotifiableValue<T> delegate;
  final T2 Function(T) block;

  const _MappedListenableNotifiableValue(this.delegate, this.block);

  @override
  void notify() => delegate.notify();

  @override
  T2 get value => block(delegate.value);
}
