import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/nested_hook.dart';

// ignore: avoid_positional_boolean_parameters
void useIf(bool condition, void Function() block) => use(_IfHook(condition, block));

final class _IfHook<T> extends Hook<T?> {
  final bool condition;
  final T Function() block;

  // ignore: avoid_positional_boolean_parameters
  const _IfHook(this.condition, this.block);

  @override
  HookState<T?, Hook<T?>> createState() => _IfHookState();
}

final class _IfHookState<T> extends NestedHookState<T?, _IfHook<T>> {
  final _key = Object();

  @override
  T? buildInner() => hook.condition ? wrapBuild(_key, hook.block) : null;
}
