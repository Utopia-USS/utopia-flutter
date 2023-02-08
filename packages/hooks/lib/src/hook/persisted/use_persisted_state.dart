import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class PersistedState<T extends Object> implements HasInitialized {
  @override
  final bool isInitialized;
  final bool isSynchronized;
  final T? value;
  final void Function(T? value) updateValue;

  const PersistedState({
    required this.isInitialized,
    required this.isSynchronized,
    required this.value,
    required this.updateValue,
  });

  bool get hasValue => value != null;
}

PersistedState<T> usePersistedState<T extends Object>(
  Future<T?> Function() get,
  Future<void> Function(T? value) set, {
  bool Function()? canGet,
  List<Object?> getKeys = const [],
}) {
  final state = useAutoComputedState(shouldCompute: canGet, compute: get, keys: getKeys);
  final submitState = useSubmitState();

  void updateValue(T? value) {
    state.updateValue(value);
    unawaited(submitState.run(() => set(value)));
  }

  final isInitialized = state.value is ComputedStateValueReady;

  return PersistedState(
    isInitialized: isInitialized,
    isSynchronized: isInitialized && !submitState.isSubmitInProgress,
    value: state.valueOrPreviousOrNull,
    updateValue: updateValue,
  );
}
