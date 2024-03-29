import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';

T useMemoized<T>(T Function() block, [HookKeys keys = const [], void Function(T)? dispose]) =>
    use(_MemoizedHook(block, keys: keys, dispose: dispose));

final class _MemoizedHook<T> extends KeyedHook<T> {
  final T Function() block;
  final void Function(T)? dispose;

  const _MemoizedHook(this.block, {this.dispose, required super.keys});

  @override
  _MemoizedHookState<T> createState() => _MemoizedHookState();
}

final class _MemoizedHookState<T> extends KeyedHookState<T, _MemoizedHook<T>> {
  late T _value;

  @override
  void init() {
    super.init();
    _value = hook.block();
  }

  @override
  void didUpdateKeys() {
    super.didUpdateKeys();
    hook.dispose?.call(_value);
    _value = hook.block();
  }

  @override
  void dispose() {
    super.dispose();
    hook.dispose?.call(_value);
  }

  @override
  T build() => _value;
}
