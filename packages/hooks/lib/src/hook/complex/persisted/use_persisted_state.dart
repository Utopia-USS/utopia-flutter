import 'dart:async';

import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/complex/computed/use_computed_state.dart';
import 'package:utopia_hooks/src/hook/complex/submit/use_submit_state.dart';
import 'package:utopia_hooks/src/hook/misc/use_previous_if_null.dart';
import 'package:utopia_hooks/src/initialization/has_initialized.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract class PersistedState<T extends Object> implements MutableValue<T?>, HasInitialized {
  abstract final bool isSynchronized;

  const PersistedState();
}

class PersistedStateImpl<T extends Object> extends PersistedState<T> {
  final bool Function() getIsInitialized;
  final bool Function() getIsSynchronized;
  final T? Function() getValue;
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

  @override
  set value(T? value) => updateValue(value);
}

PersistedState<T> usePersistedState<T extends Object>(
  Future<T?> Function() get,
  Future<void> Function(T? value) set, {
  bool canGet = true,
  HookKeys getKeys = const [],
}) {
  final state = useAutoComputedState(get, shouldCompute: canGet, keys: getKeys);
  final submitState = useSubmitState();

  void updateValue(T? value) {
    state.updateValue(value);
    unawaited(submitState.run(() => set(value)));
  }

  final wrappedValue = useValueWrapper(usePreviousIfNull(state.valueOrNull));

  return useMemoized(
    () => PersistedStateImpl(
      getIsInitialized: () => state.value is ComputedStateValueReady,
      getIsSynchronized: () => state.value is ComputedStateValueReady && !submitState.inProgress,
      getValue: wrappedValue.get,
      updateValue: updateValue,
    ),
  );
}

extension PersistedStateExtensions<T extends Object> on PersistedState<T> {
  // ignore: use_setters_to_change_properties
  void updateValue(T? value) => this.value = value;
}
