import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/effect/use_simple_effect.dart';
import 'package:utopia_hooks/src/hook/misc/use_value_wrapper.dart';

MutableComputedState<T> useComputedState<T>({required Future<T> Function() compute}) {
  final state = useState<ComputedStateValue<T>>(ComputedStateValue.notInitialized);
  final computeWrapper = useValueWrapper(compute);
  final isMounted = useIsMounted();

  Future<T> refresh() {
    final completer = CancelableCompleter<T>();
    state.value = ComputedStateValue.inProgress(completer.operation, previous: state.value);

    Future.microtask(() async {
      try {
        final result = await computeWrapper.value();
        if (!completer.isCanceled && isMounted()) {
          state.value = ComputedStateValue.ready(result);
          completer.complete(result);
        }
      } catch (e, s) {
        if (!completer.isCanceled && isMounted()) {
          state.value = ComputedStateValue.failed(e);
          completer.completeError(e, s);
        }
      }
    });

    return completer.operation.value;
  }

  Future<T> refreshOrWait() async {
    return await state.value.maybeWhen(
      inProgress: (operation, _) async => await operation.value,
      orElse: () async => await refresh(),
    );
  }

  return useMemoized(
    () => MutableComputedState(
      refresh: refreshOrWait,
      getValue: () => state.value,
      clear: () {
        state.value.maybeWhen<void>(
          inProgress: (operation, _) => operation.cancel(),
          orElse: () {},
        );
        state.value = ComputedStateValue.notInitialized;
      },
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
  final isMounted = useIsMounted();

  useSimpleEffect(() {
    state.clear();
    timerState.value?.cancel();
    timerState.value = null;
    if (shouldCompute == null || shouldCompute()) {
      if (debounceDuration == Duration.zero) {
        state.refresh();
      } else {
        timerState.value = Timer(debounceDuration, () {
          if (isMounted()) {
            state.refresh();
            timerState.value = null;
          }
        });
      }
    }
  }, keys);

  return state;
}
