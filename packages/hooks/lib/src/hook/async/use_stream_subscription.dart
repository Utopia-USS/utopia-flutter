import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

void useStreamSubscription<T>(
  Stream<T>? stream,
  void Function(T) block, {
  void Function(Object, StackTrace)? onError,
  void Function()? onDone,
}) {
  return useDebugGroup(
    debugLabel: "useStreamSubscription<$T>()",
    debugFillProperties: (properties) => properties.add(ObjectFlagProperty("stream", stream, ifNull: "no stream")),
    () {
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
    },
  );
}
