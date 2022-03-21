import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_utils/src/type/value.dart';

extension ValueNotifierExtensions<T> on ValueNotifier<T> {
  void modify(T Function(T value) block) => value = block(value);

  R mutate<R>(R Function(T value) block) {
    final result = block(value);
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    notifyListeners();
    return result;
  }

  Future<T> awaitSingle() {
    final completer = Completer<T>();
    var hasCompleted = false;
    addListener(() {
      if (!hasCompleted) {
        hasCompleted = true;
        completer.complete(value);
      }
    });
    return completer.future;
  }

  MutableValue<T> asMutableValue() => MutableValue.ofValueNotifier(this);
}

extension BoolValueNotifierExtensions on ValueNotifier<bool> {
  void toggle() => value = !value;
}
