import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';

T useMemoized<T>(T Function() block, [HookKeys keys = hookKeysEmpty, void Function(T)? dispose]) =>
    use(_MemoizedHook(block, keys: keys, dispose: dispose));

final class _MemoizedHook<T> extends KeyedHook<T> {
  final T Function() block;
  final void Function(T)? dispose;

  const _MemoizedHook(this.block, {this.dispose, required super.keys}) : super(debugLabel: 'useMemoized<$T>()');

  @override
  _MemoizedHookState<T> createState() => _MemoizedHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty('dispose', dispose, ifPresent: 'has dispose callback', level: DiagnosticLevel.debug),
    );
  }
}

final class _MemoizedHookState<T> extends KeyedHookState<T, _MemoizedHook<T>> {
  T? _value;

  @override
  void init() {
    super.init();
    _trigger(dispose: false);
  }

  @override
  void didUpdateKeys() {
    super.didUpdateKeys();
    _trigger();
  }

  @override
  void dispose() {
    _trigger(create: false);
    super.dispose();
  }

  @override
  T build() => _value as T;

  @override
  void debugMarkWillReassemble() {
    super.debugMarkWillReassemble();
    _trigger();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('value', _value));
  }

  void _trigger({bool create = true, bool dispose = true}) {
    if (dispose) hook.dispose?.call(_value as T);
    if (create) _value = hook.block();
  }
}
