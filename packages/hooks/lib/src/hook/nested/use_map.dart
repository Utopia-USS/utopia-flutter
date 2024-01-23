import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/nested_hook.dart';

Map<K, T> useMap<K extends Object, T>(Set<K> keys, T Function(K) block) => use(_MapHook(keys, block));

final class _MapHook<K extends Object, T> extends Hook<Map<K, T>> {
  final Set<K> keys;
  final T Function(K) block;

  const _MapHook(this.keys, this.block);

  @override
  _MapHookState<K, T> createState() => _MapHookState();
}

final class _MapHookState<K extends Object, T> extends NestedHookState<Map<K, T>, _MapHook<K, T>> {
  @override
  Map<K, T> buildInner() {
    return {
      for (final key in hook.keys) key: wrapBuild(key, () => hook.block(key)),
    };
  }
}
