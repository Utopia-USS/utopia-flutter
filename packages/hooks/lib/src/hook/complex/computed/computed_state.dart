import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';
import 'package:utopia_hooks/src/initialization/has_initialized.dart';

base class ComputedState<T> with ComputedStateMixin<T> {
  @override
  final ComputedStateValue<T> value;

  const ComputedState({required this.value});
}

base class RefreshableComputedState<T> with ComputedStateMixin<T> implements ComputedState<T> {
  @override
  final ComputedStateValue<T> value;

  /// If [value] is [ComputedStateValue.inProgress], waits for computation to complete.
  /// Otherwise, starts a new computation.
  final Future<void> Function() refresh;

  const RefreshableComputedState({required this.value, required this.refresh});
}

final class MutableComputedState<T> with ComputedStateMixin<T> implements RefreshableComputedState<T> {
  final ComputedStateValue<T> Function() getValue;

  @override
  final Future<T> Function() refresh;

  /// Resets [value] to [ComputedStateValue.notInitialized]
  /// Cancels the computation if [value] is [ComputedStateValue.inProgress]
  final void Function() clear;

  /// Explicitly sets [value] to [ComputedStateValue.ready] with given `value`.
  /// Cancels the computation if [value] is [ComputedStateValue.inProgress]
  final void Function(T value) updateValue;

  const MutableComputedState({
    required this.refresh,
    required this.getValue,
    required this.clear,
    required this.updateValue,
  });

  @override
  ComputedStateValue<T> get value => getValue();
}

mixin ComputedStateMixin<T> implements HasInitialized {
  abstract final ComputedStateValue<T> value;

  @override
  bool get isInitialized => value is ComputedStateValueReady;

  T? get valueOrNull => value.valueOrNull;
}
