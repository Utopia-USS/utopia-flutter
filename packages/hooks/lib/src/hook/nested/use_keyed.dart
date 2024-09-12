import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/base/nested_hook.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_utils/utopia_utils.dart';

// ignore: avoid_positional_boolean_parameters
T? useIf<T>(bool condition, T Function() block) =>
    useDebugGroup(debugLabel: 'useIf<$T>()', () => useKeyed([condition], () => condition ? block() : null));

R? useLet<T extends Object, R>(T? value, R Function(T) block) =>
    useDebugGroup(debugLabel: 'useLet<$T, $R>()', () => useKeyed([value], () => value?.let(block)));

T useKeyed<T>(HookKeys keys, T Function() block) => use(_KeyedHook(keys, block));

class _KeyedHook<T> extends Hook<T> {
  final HookKeys keys;
  final T Function() block;

  // ignore: avoid_positional_boolean_parameters
  const _KeyedHook(this.keys, this.block) : super(debugLabel: "useKeyed<$T>()");

  @override
  _KeyedHookState<T> createState() => _KeyedHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(HookKeysProperty(keys));
  }
}

final class _KeyedHookState<T> extends NestedHookState<T, _KeyedHook<T>> {
  @override
  T buildInner() => wrapBuild(hook.keys, hook.block);
}
