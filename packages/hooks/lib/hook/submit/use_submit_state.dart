import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/hook/submit/submit_error.dart';
import 'package:utopia_hooks/hook/submit/submit_result.dart';
import 'package:utopia_hooks/hook/submit/submit_state.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

MutableSubmitState<void, T, Never> useSubmitStateSimple<T>({
  FutureOr<bool> Function()? shouldSubmit,
  FutureOr<SubmitResult<T, Never>?> Function()? afterShouldNotSubmit,
  FutureOr<void> Function()? beforeSubmit,
  required Future<T> Function() submit,
  FutureOr<void> Function(T)? afterSubmit,
  Function(SubmitErrorUnknown)? afterError,
}) {
  return useSubmitState<void, T, Never>(
    shouldSubmit: (_) => shouldSubmit?.call() ?? true,
    afterShouldNotSubmit: (_) => afterShouldNotSubmit?.call(),
    beforeSubmit: (_) => beforeSubmit?.call(),
    submit: (_) => submit(),
    afterSubmit: (_, result) => afterSubmit?.call(result),
    afterError: (e) => afterError?.call(e as SubmitErrorUnknown),
  );
}

MutableSubmitState<I, T, E> useSubmitState<I, T, E>({
  FutureOr<bool> Function(I)? shouldSubmit,
  FutureOr<SubmitResult<T, E>?> Function(I)? afterShouldNotSubmit,
  FutureOr<void> Function(I)? beforeSubmit,
  required Future<T> Function(I) submit,
  FutureOr<SubmitError<E>> Function(Object)? mapError,
  FutureOr<void> Function(I, T)? afterSubmit,
  Function(SubmitError)? afterError,
}) {
  final isSubmitInProgressState = useState<bool>(false);
  final unknownErrorStream = useStreamController<SubmitErrorUnknown>();

  Future<SubmitResult<T, E>> trySubmit(I input) async {
    if (isSubmitInProgressState.value) return SubmitResult.alreadySubmitting();

    try {
      isSubmitInProgressState.value = true;

      if (shouldSubmit != null && !await shouldSubmit(input)) {
        final result = await afterShouldNotSubmit?.call(input);
        return result ?? SubmitResult.shouldNotSubmit();
      }

      await beforeSubmit?.call(input);
      final result = await submit(input);
      await afterSubmit?.call(input, result);

      return SubmitResult.success(result);
    } catch (e, s) {
      final error = await mapError?.call(e) ?? SubmitError.unknown(e, s);

      if (error is SubmitErrorUnknown) {
        UtopiaHooks.reporter?.error('Unknown error in SubmitState', e, s);
        unknownErrorStream.add(error);
      }

      await afterError?.call(error);

      return SubmitResult.error(error);
    } finally {
      isSubmitInProgressState.value = false;
    }
  }

  return MutableSubmitState(
    isSubmitInProgress: isSubmitInProgressState.value,
    unknownErrorStream: unknownErrorStream.stream,
    submitWithInput: trySubmit,
  );
}
