import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

enum StreamSubscriptionStrategy {
  parallel,
  pause,
  drop,
}

void useStreamSubscription<T>(
  Stream<T>? stream,
  FutureOr<void> Function(T) block, {
  void Function(Object, StackTrace)? onError,
  void Function()? onDone,
  StreamSubscriptionStrategy strategy = StreamSubscriptionStrategy.parallel,
}) {
  return useDebugGroup(
    debugLabel: "useStreamSubscription<$T>()",
    debugFillProperties: (properties) => properties
      ..add(EnumProperty("strategy", strategy, defaultValue: StreamSubscriptionStrategy.parallel))
      ..add(ObjectFlagProperty("stream", stream, ifNull: "no stream")),
    () {
      final wrappedBlock = useValueWrapper(block);
      final wrappedOnError = useValueWrapper(onError ?? Zone.current.handleUncaughtError);
      final wrappedOnDone = useValueWrapper(onDone ?? () {});

      final isMounted = useIsMounted();
      final isHandlingState = useState(false, listen: false);

      Future<void> handle(StreamSubscription<T> subscription, T value) async {
        if(!isMounted()) return;
        switch (strategy) {
          case StreamSubscriptionStrategy.parallel:
            break;
          case StreamSubscriptionStrategy.pause:
            subscription.pause();
          case StreamSubscriptionStrategy.drop:
            if (isHandlingState.value) return;
        }
        isHandlingState.value = true;
        try {
          await wrappedBlock.value(value);
        } finally {
          if(isMounted()) isHandlingState.value = false;
          subscription.resume();
        }
      }

      useEffect(() {
        final subscription = stream?.listen(
          null,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace stackTrace) => wrappedOnError.value(error, stackTrace),
          onDone: () => wrappedOnDone.value(),
        );
        subscription?.onData((it) => unawaited(handle(subscription, it)));
        return () => unawaited(subscription?.cancel());
      }, [stream]);
    },
  );
}
