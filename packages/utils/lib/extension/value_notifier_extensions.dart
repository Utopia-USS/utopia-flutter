import 'dart:async';

import 'package:flutter/foundation.dart';

extension ValueNotifierExtensions<T> on ValueNotifier<T> {
  Future<T> awaitSingle() {
    final completer = Completer<T>();
    var hasCompleted = false;
    addListener(() {
      if(!hasCompleted) {
        hasCompleted = true;
        completer.complete(value);
      }
    });
    return completer.future;
  }
}
