import 'dart:async';

import 'package:async/async.dart';
import 'package:utopia_utils/utopia_utils.dart';

import 'submit_error.dart';
import 'submit_result.dart';

// for convenience
export 'submit_state_extensions.dart';

class SubmitState {
  final bool isSubmitInProgress;
  final Stream<void> unknownErrorStream;

  const SubmitState({required this.isSubmitInProgress, required this.unknownErrorStream});

  static SubmitState combine(List<SubmitState> states) {
    return SubmitState(
      isSubmitInProgress: anyTrue(states.map((it) => it.isSubmitInProgress)),
      unknownErrorStream: StreamGroup.merge(states.map((it) => it.unknownErrorStream)),
    );
  }
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
