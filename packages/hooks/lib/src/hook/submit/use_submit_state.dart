import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

MutableSubmitState useSubmitState() {
  final submitCountState = useState(0);

  Future<T> run<T>(Future<T> Function() block, {bool isRetryable = true}) async {
    submitCountState.value++;
    try {
      return await block();
    } catch (e) {
      if (isRetryable) Retryable.make(e, () => run(block, isRetryable: isRetryable));
      rethrow;
    } finally {
      submitCountState.value--;
    }
  }

  return MutableSubmitState(isSubmitInProgress: submitCountState.value > 0, run: run);
}
