import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/complex/computed/use_computed_state.dart';
import 'package:utopia_hooks/src/hook/complex/submit/use_submit_state.dart';
import 'package:utopia_hooks/src/hook/misc/use_previous_if_null.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_hooks/src/misc/has_initialized.dart';
import 'package:utopia_utils/utopia_utils.dart';

abstract interface class PersistedState<T extends Object> implements MutableValue<T?>, HasInitialized {
  abstract final bool isSynchronized;
}

PersistedState<T> usePersistedState<T extends Object>(
  Future<T?> Function() get,
  Future<void> Function(T? value) set, {
  bool canGet = true,
  HookKeys getKeys = hookKeysEmpty,
}) {
  return useDebugGroup(
    debugLabel: "usePersistedState<$T>()",
    debugFillProperties: (builder) => builder
      ..add(FlagProperty("can get", value: canGet, ifFalse: "fetching disabled"))
      ..add(IterableProperty("get keys", getKeys, ifEmpty: null)),
    () {
      final state = useAutoComputedState(get, shouldCompute: canGet, keys: getKeys);
      final submitState = useSubmitState();

      final wrappedSet = useValueWrapper(set);

      void updateValue(T? value) {
        state.updateValue(value);
        unawaited(submitState.run(() => wrappedSet.value(value)));
      }

      final wrappedValue = useValueWrapper(usePreviousIfNull(state.valueOrNull));

      return useMemoized(
        () => _DelegatePersistedState(
          getIsInitialized: () => state.value is ComputedStateValueReady,
          getIsSynchronized: () => state.value is ComputedStateValueReady && !submitState.inProgress,
          getValue: wrappedValue.get,
          setValue: updateValue,
        ),
      );
    },
  );
}

class _DelegatePersistedState<T extends Object> implements PersistedState<T> {
  final bool Function() getIsInitialized;
  final bool Function() getIsSynchronized;
  final T? Function() getValue;
  final void Function(T? value) setValue;

  const _DelegatePersistedState({
    required this.getIsInitialized,
    required this.getIsSynchronized,
    required this.getValue,
    required this.setValue,
  });

  @override
  bool get isInitialized => getIsInitialized();

  @override
  bool get isSynchronized => getIsSynchronized();

  @override
  T? get value => getValue();

  @override
  set value(T? value) => setValue(value);
}
