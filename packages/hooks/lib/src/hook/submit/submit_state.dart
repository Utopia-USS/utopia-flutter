import 'dart:async';

import 'submit_error.dart';
import 'submit_result.dart';

// for convenience
export 'submit_state_extensions.dart';

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
