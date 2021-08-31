import 'dart:async';

import 'package:utopia_hooks/hook/submit/submit_error.dart';
import 'package:utopia_hooks/hook/submit/submit_result.dart';

abstract class SubmitState {
  bool get isSubmitInProgress;
  Stream<void> get unknownErrorStream;
}

class MutableSubmitState<I, T, E> implements SubmitState {
  final bool isSubmitInProgress;
  final Stream<SubmitErrorUnknown> unknownErrorStream;
  final Future<SubmitResult<T, E>> Function(I) submitWithInput;

  MutableSubmitState({
    required this.isSubmitInProgress,
    required this.unknownErrorStream,
    required this.submitWithInput,
  });
}

extension MutableSubmitStateExtensions<T, E> on MutableSubmitState<void, T, E> {
  Future<SubmitResult<T, E>> submit() => submitWithInput(null);
}
