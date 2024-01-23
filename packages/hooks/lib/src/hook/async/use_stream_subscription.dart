import 'dart:async';

import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';

void useStreamSubscription<T>(
  Stream<T>? stream,
  void Function(T) block, {
  void Function(Object, StackTrace)? onError,
  void Function()? onDone,
}) {
  final wrappedBlock = useValueWrapper(block);
  final wrappedOnError = useValueWrapper(onError ?? Zone.current.handleUncaughtError);
  final wrappedOnDone = useValueWrapper(onDone ?? () {});

  useEffect(() {
    final subscription = stream?.listen(
      (it) => wrappedBlock.value(it),
      // ignore: avoid_types_on_closure_parameters
      onError: (Object error, StackTrace stackTrace) => wrappedOnError.value(error, stackTrace),
      onDone: () => wrappedOnDone.value(),
    );
    return () => unawaited(subscription?.cancel());
  }, [stream]);
}
