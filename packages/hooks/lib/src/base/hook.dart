import 'package:meta/meta.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:flutter/foundation.dart';

abstract base class Hook<T> {
  const Hook();

  HookState<T, Hook<T>> createState();
}

abstract base class HookState<T, H extends Hook<T>> {
  late H hook;

  late HookContext context;

  @mustCallSuper
  void init() {}

  @mustCallSuper
  void dispose() {}

  @mustCallSuper
  void didUpdate(H oldHook) {}

  T build();
}

typedef HookKeys = List<Object?>;

abstract base class KeyedHook<T> extends Hook<T> {
  final HookKeys keys;

  const KeyedHook({required this.keys});

  @override
  KeyedHookState<T, KeyedHook<T>> createState();
}

abstract base class KeyedHookState<T, H extends KeyedHook<T>> extends HookState<T, H> {
  @mustCallSuper
  void didUpdateKeys() {}

  @override
  @mustCallSuper
  void didUpdate(H oldHook) {
    super.didUpdate(oldHook);
    if (!_keysEqual(hook.keys, oldHook.keys)) didUpdateKeys();
  }

  static bool _keysEqual(HookKeys a, HookKeys b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
