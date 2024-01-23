import 'dart:async';

import 'package:utopia_hooks/src/hook/base/use_memoized.dart';

StreamController<T> useStreamController<T>() =>
    useMemoized(StreamController.broadcast, [], (it) => unawaited(it.close()));
