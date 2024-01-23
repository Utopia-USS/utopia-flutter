import 'dart:async';

import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/complex/submit/submit_state.dart';
import 'package:utopia_utils/utopia_utils.dart';

MutableSubmitState useSubmitState() {
  final submitCountState = useState(0);
  final isMounted = useIsMounted();

  Future<T> run<T>(Future<T> Function() block, {bool isRetryable = true}) async {
    if (isMounted()) submitCountState.value++;
    try {
      return await block();
    } catch (e) {
      if (isRetryable) Retryable.make(e, () => run(block, isRetryable: isRetryable));
      rethrow;
    } finally {
      if (isMounted()) submitCountState.value--;
    }
  }

  return MutableSubmitState(inProgress: submitCountState.value > 0, run: run);
}
