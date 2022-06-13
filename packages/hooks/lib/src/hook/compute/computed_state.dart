import 'package:utopia_hooks/utopia_hooks.dart';

class ComputedState<T> {
  final ComputedStateValue<T> value;

  const ComputedState({required this.value});

  // copied between implementations for convenience
  T? get valueOrNull => value.valueOrNull;
  T? get previousValueOrNull => value.previousValueOrNull;
  T? get valueOrPreviousOrNull => value.valueOrPreviousOrNull;
}

class RefreshableComputedState<T> implements ComputedState<T> {
  @override
  final ComputedStateValue<T> value;

  /// If [value] is [ComputedStateValue.inProgress], waits for computation to complete.
  /// Otherwise, starts a new computation.
  final Future<void> Function() refresh;

  const RefreshableComputedState({required this.value, required this.refresh});

  // copied between implementations for convenience
  @override
  T? get valueOrNull => value.valueOrNull;

  @override
  T? get previousValueOrNull => value.previousValueOrNull;

  @override
  T? get valueOrPreviousOrNull => value.valueOrPreviousOrNull;
}

class MutableComputedState<T> implements RefreshableComputedState<T> {
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

  // copied between implementations for convenience
  @override
  T? get valueOrNull => value.valueOrNull;

  @override
  T? get previousValueOrNull => value.previousValueOrNull;

  @override
  T? get valueOrPreviousOrNull => value.valueOrPreviousOrNull;

  @Deprecated("Use just refresh() instead")
  Future<T> tryRefresh() => refresh();
}
