import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';

// for convenience
export 'submit_state_extensions.dart';

MutableSubmitState<void, T, Never> useSubmitStateSimple<T>({
  FutureOr<bool> Function()? shouldSubmit,
  FutureOr<SubmitResult<T, Never>?> Function()? afterShouldNotSubmit,
  FutureOr<void> Function()? beforeSubmit,
  required Future<T> Function() submit,
  FutureOr<void> Function(T)? afterSubmit,
  void Function(SubmitErrorUnknown)? afterError,
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
  FutureOr<void> Function(SubmitError<E>)? afterError,
}) {
  final isSubmitInProgressState = useState<bool>(false);
  final unknownErrorStream = useStreamController<SubmitErrorUnknown>();
  final isMounted = useIsMounted();

  Future<SubmitResult<T, E>> trySubmit(I input) async {
    if (isSubmitInProgressState.value) return const SubmitResult.alreadySubmitting();

    try {
      isSubmitInProgressState.value = true;

      if (shouldSubmit != null && !await shouldSubmit(input)) {
        final result = await afterShouldNotSubmit?.call(input);
        return result ?? const SubmitResult.shouldNotSubmit();
      }

      await beforeSubmit?.call(input);
      final result = await submit(input);
      await afterSubmit?.call(input, result);

      return SubmitResult.success(result);
    } catch (e, s) {
      final error = await mapError?.call(e) ?? SubmitError.unknown(e, s);

      if (error is SubmitErrorUnknown) {
        UtopiaHooks.reporter?.error('Unknown error in SubmitState', e: e, s: s);
        if(isMounted()) unknownErrorStream.add(error);
      }

      await afterError?.call(error);

      return SubmitResult.error(error);
    } finally {
      if(isMounted()) isSubmitInProgressState.value = false;
    }
  }

  return MutableSubmitState(
    isSubmitInProgress: isSubmitInProgressState.value,
    unknownErrorStream: unknownErrorStream.stream,
    submitWithInput: trySubmit,
  );
}
