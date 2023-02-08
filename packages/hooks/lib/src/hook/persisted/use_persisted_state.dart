import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract class PersistedState<T extends Object> implements HasInitialized {
  abstract final bool isSynchronized;
  abstract final T? value;
  abstract final void Function(T? value) updateValue;

  const PersistedState();

  bool get hasValue => value != null;
}

class PersistedStateImpl<T extends Object> extends PersistedState<T> {
  final bool Function() getIsInitialized;
  final bool Function() getIsSynchronized;
  final T? Function() getValue;

  @override
  final void Function(T? value) updateValue;

  const PersistedStateImpl({
    required this.getIsInitialized,
    required this.getIsSynchronized,
    required this.getValue,
    required this.updateValue,
  });

  @override
  bool get isInitialized => getIsInitialized();

  @override
  bool get isSynchronized => getIsSynchronized();

  @override
  T? get value => getValue();
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

  return useMemoized(
    () => PersistedStateImpl(
      getIsInitialized: () => state.value is ComputedStateValueReady,
      getIsSynchronized: () => state.value is ComputedStateValueReady && !submitState.isSubmitInProgress,
      getValue: () => state.valueOrPreviousOrNull,
      updateValue: updateValue,
    ),
  );
}
