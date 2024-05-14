import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';
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
  R mutate<R>(R Function(T it) block) {
    final result = block(value);
    notify();
    return result;
  }

  void maybeMutate(bool Function(T it) block) => notifyIf(block(value));
}
