import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/effect/use_simple_effect.dart';
import 'package:utopia_hooks/src/hook/misc/use_value_wrapper.dart';

MutableComputedState<T> useComputedState<T>({required Future<T> Function() compute}) {
  final state = useState<ComputedStateValue<T>>(ComputedStateValue.notInitialized);
  final computeWrapper = useValueWrapper(compute);

  Future<T> tryRefresh() {
    final future = Future.microtask(() async {
      try {
        final result = await computeWrapper.value();
        state.value.maybeWhen(
          inProgress: (_) => state.value = ComputedStateValue.ready(result),
          orElse: () {}, // computation has been interrupted
        );
        return result;
      } catch (e) {
        state.value = ComputedStateValue.failed(e);
        rethrow;
      }
    });
    state.value = ComputedStateValue.inProgress(future);
    return future;
  }

  Future<T> tryRefreshOrWait() async {
    return await state.value.maybeWhen(
      inProgress: (future) async => await future,
      orElse: () async => await tryRefresh(),
    );
  }

  return useMemoized(
    () => MutableComputedState(
      tryRefresh: tryRefreshOrWait,
      getValue: () => state.value,
      clear: () => state.value = ComputedStateValue.notInitialized,
      updateValue: (value) => state.value = ComputedStateValue.ready(value),
    ),
  );
}

/// Allows for automatic refreshing of [ComputedState] in response to changes in [keys].
/// Refreshes also on first call.
///
/// [shouldCompute] can be passed to decide if [compute] should be called when [keys] change.
/// **If [shouldCompute] returns `false`, state is cleared immediately.**
///
/// [debounceDuration] allows for setting a delay, which must pass between [keys] changes to trigger [compute].
MutableComputedState<T> useAutoComputedState<T>({
  required Future<T> Function() compute,
  bool Function()? shouldCompute,
  required List<Object?> keys,
  Duration debounceDuration = Duration.zero,
}) {
  final state = useComputedState<T>(compute: compute);

  final timerState = useState<Timer?>(null);

  useSimpleEffect(() {
    if (shouldCompute == null || shouldCompute()) {
      timerState.value?.cancel();
      timerState.value = Timer(debounceDuration, () {
        state.refresh();
        timerState.value = null;
      });
    } else {
      state.clear();
      timerState.value?.cancel();
      timerState.value = null;
    }
  }, keys);

  return state;
}
