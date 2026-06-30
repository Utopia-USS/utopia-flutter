import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_hooks/src/misc/refresh_cancellation.dart';
import 'package:utopia_utils/utopia_utils.dart';

/// Returns a [MutableComputedState] driven by [compute], which is run on demand via [MutableComputedState.refresh].
///
/// Unlike [useAutoComputedState], [compute] is **not** called automatically — nothing runs until [MutableComputedState.refresh] is called.
///
/// If [isRetryable] is `true`, errors thrown by [compute] are made [Retryable] via [Retryable.make],
/// allowing consumers to call [Retryable.tryGet] and [Retryable.retry] to re-run [compute].
MutableComputedState<T> useComputedState<T>(Future<T> Function() compute, {bool isRetryable = false}) {
  return useDebugGroup(
    debugLabel: 'useComputedState<$T>()',
    debugFillProperties: (properties) =>
        properties.add(FlagProperty("isRetryable", value: isRetryable, ifTrue: 'retryable')),
    () => _useComputedState(compute, isRetryable: isRetryable),
  );
}

/// Allows for automatic refreshing of [ComputedState] in response to changes in [keys].
/// Refreshes also on first call.
///
/// [shouldCompute] can be passed to decide if [compute] should be called when [keys] change.
/// **If [shouldCompute] returns `false`, state is cleared immediately.**
///
/// [debounceDuration] allows for setting a delay, which must pass between [keys] changes to trigger [compute].
///
/// If [isRetryable] is `true`, errors thrown by [compute] are made [Retryable] via [Retryable.make],
/// allowing consumers to call [Retryable.tryGet] and [Retryable.retry] to re-run [compute].
/// Note that [shouldCompute] can change in the meantime which can have unintended consequences when [Retryable.retry] is called later.
MutableComputedState<T> useAutoComputedState<T>(
  Future<T> Function() compute, {
  bool shouldCompute = true,
  HookKeys keys = hookKeysEmpty,
  Duration debounceDuration = Duration.zero,
  bool isRetryable = false,
}) {
  return useDebugGroup(
    debugLabel: 'useAutoComputedState<$T>()',
    debugFillProperties: (properties) => properties
      ..add(DiagnosticsProperty("shouldCompute", shouldCompute, defaultValue: true))
      ..add(IterableProperty("keys", keys, defaultValue: hookKeysEmpty))
      ..add(DiagnosticsProperty("debounceDuration", debounceDuration, defaultValue: Duration.zero))
      ..add(FlagProperty("isRetryable", value: isRetryable, ifTrue: 'retryable')),
    () {
      final state = _useComputedState(compute, isRetryable: isRetryable);
      final timerState = useState<Timer?>(null);
      final isMounted = useIsMounted();

      useEffect(() {
        state.clear();
        timerState.value?.cancel();
        timerState.value = null;
        if (shouldCompute) {
          if (debounceDuration == Duration.zero) {
            state.refresh().ignoreRefreshCancellation();
          } else {
            timerState.value = Timer(debounceDuration, () {
              if (isMounted()) {
                state.refresh().ignoreRefreshCancellation();
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

MutableComputedState<T> _useComputedState<T>(Future<T> Function() compute, {bool isRetryable = false}) {
  final state = useState<ComputedStateValue<T>>(ComputedStateValue.notInitialized);
  final computeWrapper = useValueWrapper(compute);
  final isMounted = useIsMounted();

  late Future<T> Function() refresh;
  refresh = () {
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
        if (isRetryable) Retryable.make(e, refresh);
        if (!completer.isCanceled && isMounted()) {
          state.value = ComputedStateValue.failed(e);
          completer.completeError(e, s);
        }
      }
    }).ignore();

    return completer.operation.valueOrThrowIfCancelled();
  };

  Future<T> refreshOrWait() async {
    return await state.value.maybeWhen(
      inProgress: (operation) => operation.valueOrThrowIfCancelled(),
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
      updateValue: (value) {
        state.value.maybeWhen<void>(
          inProgress: (operation) => unawaited(operation.cancel()),
          orElse: () {},
        );
        state.value = ComputedStateValue.ready(value);
      },
    ),
  );
}
