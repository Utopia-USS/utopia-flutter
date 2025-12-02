import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/base/nested_hook.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_utils/utopia_utils.dart';

// ignore: avoid_positional_boolean_parameters
T? useIf<T>(bool condition, T Function() block) =>
    useDebugGroup(debugLabel: 'useIf<$T>()', () => useKeyed([condition], () => condition ? block() : null));

R? useIfNotNull<T extends Object, R>(T? value, R Function(T) block) =>
    useDebugGroup(debugLabel: 'useIfNotNull<$T, $R>()', () => useKeyed([value != null], () => value?.let(block)));

@Deprecated("Confusing behavior, use useIfNotNull or useKeyed instead")
R? useLet<T extends Object, R>(T? value, R Function(T) block) =>
    useDebugGroup(debugLabel: 'useLet<$T, $R>()', () => useKeyed([value], () => value?.let(block)));

T useKeyed<T>(HookKeys keys, T Function() block) => use(_KeyedHook(block, keys: keys));

class _KeyedHook<T> extends KeyedHook<T> {
  final T Function() block;

  const _KeyedHook(this.block, {required super.keys}) : super(debugLabel: "useKeyed<$T>()");

  @override
  _KeyedHookState<T> createState() => _KeyedHookState();
}

final class _KeyedHookState<T> extends SingleNestedHookState<T, _KeyedHook<T>> {
  @override
  T buildNested() => hook.block();
}
