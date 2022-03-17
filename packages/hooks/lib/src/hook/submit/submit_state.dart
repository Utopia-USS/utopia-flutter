import 'dart:async';

import 'package:utopia_utils/utopia_utils.dart';

class SubmitState {
  final bool isSubmitInProgress;

  const SubmitState({required this.isSubmitInProgress});

  static SubmitState combine(List<SubmitState> states) =>
      SubmitState(isSubmitInProgress: anyTrue(states.map((it) => it.isSubmitInProgress)));
}

class MutableSubmitState implements SubmitState {
  @override
  final bool isSubmitInProgress;

  final Future<T> Function<T>(Future<T> Function() block, {bool isRetryable}) run;

  const MutableSubmitState({
    required this.isSubmitInProgress,
    required this.run,
  });

  Future<void> runSimple<T, E>({
    FutureOr<bool> Function()? shouldSubmit,
    FutureOr<void> Function()? afterShouldNotSubmit,
    FutureOr<void> Function()? beforeSubmit,
    required Future<T> Function() submit,
    FutureOr<void> Function(T)? afterSubmit,
    FutureOr<E?> Function(Object)? mapError,
    FutureOr<void> Function(E)? afterKnownError,
    FutureOr<void> Function()? afterError,
    bool isRetryable = true,
  }) async {
    if (shouldSubmit == null || !await shouldSubmit()) {
      await afterShouldNotSubmit?.call();
      return;
    }
    await run(() async {
      try {
        await beforeSubmit?.call();
        final result = await submit();
        await afterSubmit?.call(result);
      } catch (e) {
        await afterError?.call();
        final mappedError = await mapError?.call(e);
        if (mappedError != null) {
          await afterKnownError?.call(mappedError);
        } else {
          rethrow;
        }
      }
    }, isRetryable: isRetryable);
  }
}
