import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/hook/compute/computed_state.dart';
import 'package:utopia_hooks/hook/effect/use_simple_effect.dart';
import 'package:utopia_hooks/hook/misc/use_value_wrapper.dart';
import 'package:utopia_utils/extension/extensions.dart';

MutableComputedState<T> useComputedState<T>({required Future<T> Function() compute}) {
  final state = useState<T?>(null);
  final modeState = useState<ComputedStateMode>(ComputedStateMode.notInitialized);
  final computeWrapper = useValueWrapper(compute);

  Future<T?> performCompute() async {
    modeState.value = ComputedStateMode.inProgress;
    try {
      final value = await computeWrapper.value();
      if (modeState.value != ComputedStateMode.inProgress) {
        // computation has been interrupted by explicit setValue
        return state.value;
      } else {
        state.value = value;
        modeState.value = ComputedStateMode.ready;
        return value;
      }
    } catch (e) {
      modeState.value = ComputedStateMode.failed;
      rethrow;
    }
  }

  Future<T?> performComputeOrWait() async {
    if (modeState.value == ComputedStateMode.inProgress) {
      await modeState.awaitSingle();
      return state.value as T;
    } else {
      return await performCompute();
    }
  }

  return useMemoized(
    () => MutableComputedState(
      refresh: performComputeOrWait,
      getMode: () => modeState.value,
      getValue: () => state.value,
      clear: () {
        modeState.value = ComputedStateMode.notInitialized;
        state.value = null;
      },
      updateValue: (value) {
        modeState.value = ComputedStateMode.ready; // stop any pending computation
        state.value = value;
      },
    ),
  );
}

MutableComputedState<T> useAutoComputedState<T>({
  required Future<T> Function() compute,
  bool Function()? shouldCompute,
  required List<Object?> keys,
  Duration debounceDuration = Duration.zero,
}) {
  final state = useComputedState<T>(compute: compute);

  final timerState = useState<Timer?>(null);

  useSimpleEffect(() {
    state.clear();
    if (shouldCompute == null || shouldCompute()) {
      timerState.value?.cancel();
      timerState.value = Timer(debounceDuration, () {
        state.refresh();
        timerState.value = null;
      });
    } else {
      timerState.value?.cancel();
      timerState.value = null;
    }
  }, keys);

  return state;
}
