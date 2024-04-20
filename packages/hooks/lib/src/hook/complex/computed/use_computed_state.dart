import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

MutableComputedState<T> useComputedState<T>(Future<T> Function() compute) =>
    useDebugGroup(debugLabel: 'useComputedState<$T>()', () => _useComputedState(compute));

/// Allows for automatic refreshing of [ComputedState] in response to changes in [keys].
/// Refreshes also on first call.
///
/// [shouldCompute] can be passed to decide if [compute] should be called when [keys] change.
/// **If [shouldCompute] returns `false`, state is cleared immediately.**
///
/// [debounceDuration] allows for setting a delay, which must pass between [keys] changes to trigger [compute].
MutableComputedState<T> useAutoComputedState<T>(
  Future<T> Function() compute, {
  bool shouldCompute = true,
  HookKeys keys = const [],
  Duration debounceDuration = Duration.zero,
}) {
  return useDebugGroup(
    debugLabel: 'useAutoComputedState<$T>()',
    debugFillProperties: (properties) => properties
      ..add(DiagnosticsProperty("shouldCompute", shouldCompute, defaultValue: true))
      ..add(IterableProperty("keys", keys, defaultValue: const []))
      ..add(DiagnosticsProperty("debounceDuration", debounceDuration, defaultValue: Duration.zero)),
    () {
      final state = _useComputedState(compute);
      final timerState = useState<Timer?>(null);
      final isMounted = useIsMounted();

      useEffect(() {
        state.clear();
        timerState.value?.cancel();
        timerState.value = null;
        if (shouldCompute) {
          if (debounceDuration == Duration.zero) {
            unawaited(state.refresh());
          } else {
            timerState.value = Timer(debounceDuration, () {
              if (isMounted()) {
                unawaited(state.refresh());
                timerState.value = null;
              }
            });
          }
        }
      }, [shouldCompute, ...keys]);

      return state;
    },
  );
}

MutableComputedState<T> _useComputedState<T>(Future<T> Function() compute) {
  final state = useState<ComputedStateValue<T>>(ComputedStateValue.notInitialized);
  final computeWrapper = useValueWrapper(compute);
  final isMounted = useIsMounted();

  Future<T> refresh() {
    final completer = CancelableCompleter<T>();
    state.value = ComputedStateValue.inProgress(completer.operation);

    Future.sync(() async {
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
      inProgress: (operation) async => operation.value,
      orElse: () async => refresh(),
    );
  }

  return useMemoized(
    () => MutableComputedState(
      refresh: refreshOrWait,
      getValue: () => state.value,
      clear: () {
        state.value.maybeWhen<void>(
          inProgress: (operation) => unawaited(operation.cancel()),
          orElse: () {},
        );
        state.value = ComputedStateValue.notInitialized;
      },
      updateValue: (value) => state.value = ComputedStateValue.ready(value),
    ),
  );
}
