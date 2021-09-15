import 'package:utopia_hooks/hook/compute/computed_state_value.dart';

class ComputedState<T> {
  final ComputedStateValue<T> value;

  const ComputedState({required this.value});

  // copied between implementations for convenience
  T? get valueOrNull => value.valueOrNull;
}

class RefreshableComputedState<T> implements ComputedState<T> {
  final ComputedStateValue<T> value;

  /// If [value] is [ComputedStateValue.inProgress], waits for computation to complete.
  /// Otherwise, starts a new computation.
  /// This method is meant to be called from views, so it **will never throw**.
  /// It completes with success, even if the computation fails.
  /// To handle errors, use [MutableComputedState.tryRefresh]
  final Future<void> Function() refresh;

  const RefreshableComputedState({required this.value, required this.refresh});

  // copied between implementations for convenience
  @override
  T? get valueOrNull => value.valueOrNull;
}

class MutableComputedState<T> implements RefreshableComputedState<T> {
  final ComputedStateValue<T> Function() getValue;

  /// See [RefreshableComputedState.refresh]
  final Future<T> Function() tryRefresh;

  /// Resets [value] to [ComputedStateValue.notInitialized]
  /// Cancels the computation if [value] is [ComputedStateValue.inProgress]
  final Function() clear;

  /// Explicitly sets [value] to [ComputedStateValue.ready] with given `value`.
  /// Cancels the computation if [value] is [ComputedStateValue.inProgress]
  final Function(T value) updateValue;

  const MutableComputedState({
    required this.tryRefresh,
    required this.getValue,
    required this.clear,
    required this.updateValue,
  });

  // defined as a getter to conform to superclass' interface
  @override
  Future<void> Function() get refresh => () => tryRefresh().then((_) => null, onError: (_) => null);

  @override
  ComputedStateValue<T> get value => getValue();

  // copied between implementations for convenience
  @override
  T? get valueOrNull => value.valueOrNull;
}
