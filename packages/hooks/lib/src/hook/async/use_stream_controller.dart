import 'dart:async';

import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

StreamController<T> useStreamController<T>() {
  return useDebugGroup(
    debugLabel: "useStreamController<$T>()",
    () => useMemoized(StreamController.broadcast, [], (it) => unawaited(it.close())),
  );
}
