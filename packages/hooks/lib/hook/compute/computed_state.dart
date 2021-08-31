enum ComputedStateMode {
  notInitialized,
  inProgress,
  ready,
  failed,
}

class ComputedState<T> {
  final T? value;
  final ComputedStateMode mode;

  const ComputedState({required this.value, required this.mode});
}

class RefreshableComputedState<T> implements ComputedState<T> {
  final T? value;
  final ComputedStateMode mode;
  final Future<void> Function() refresh;

  const RefreshableComputedState({required this.value, required this.mode, required this.refresh});
}

class MutableComputedState<T> implements RefreshableComputedState<T> {
  final Future<T?> Function() refresh;
  final ComputedStateMode Function() getMode;
  final T? Function() getValue;
  final Function() clear;
  final Function(T? value) updateValue;

  const MutableComputedState({
    required this.refresh,
    required this.getMode,
    required this.getValue,
    required this.clear,
    required this.updateValue,
  });

  ComputedStateMode get mode => getMode();

  T? get value => getValue();
}