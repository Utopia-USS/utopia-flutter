import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';

/// Standard type for keys used in [KeyedHook] and other hooks.
///
/// Hooks that take
typedef HookKeys = List<Object?>;

const hookKeysEmpty = <Object?>[];

const hookKeysEquality = ListEquality<Object?>();

class HookKeysEquatable {
  final HookKeys keys;

  const HookKeysEquatable(this.keys);

  @override
  bool operator ==(Object other) => other is HookKeysEquatable && hookKeysEquality.equals(keys, other.keys);

  @override
  int get hashCode => hookKeysEquality.hash(keys);
}

abstract class KeyedHook<T> extends Hook<T> {
  final HookKeys keys;

  const KeyedHook({required this.keys, super.debugLabel});

  @override
  KeyedHookState<T, KeyedHook<T>> createState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(HookKeysProperty(keys));
  }
}

abstract class KeyedHookState<T, H extends KeyedHook<T>> extends HookState<T, H> {
  @mustCallSuper
  void didUpdateKeys() {}

  @override
  @mustCallSuper
  void didUpdate(H oldHook) {
    super.didUpdate(oldHook);
    if (!hookKeysEquality.equals(hook.keys, oldHook.keys)) didUpdateKeys();
  }
}

class HookKeysProperty extends IterableProperty<Object?> {
  HookKeysProperty(HookKeys value, {String name = "keys", super.ifEmpty = "no keys", super.level}) : super(name, value);
}
