import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

void useListenable(Listenable? listenable) => use(_ListenableHook(listenable));

T useValueListenable<T>(ValueListenable<T> listenable) {
  useListenable(listenable);
  return listenable.value;
}

T useListenableValue<T>(ListenableValue<T> listenable) {
  useListenable(listenable);
  return listenable.value;
}

final class _ListenableHook extends Hook<void> {
  const _ListenableHook(this.listenable);

  final Listenable? listenable;

  @override
  _ListenableHookState createState() => _ListenableHookState();
}

final class _ListenableHookState extends HookState<void, _ListenableHook> {
  @override
  void init() {
    super.init();
    hook.listenable?.addListener(context.markNeedsBuild);
  }

  @override
  void didUpdate(_ListenableHook oldHook) {
    super.didUpdate(oldHook);
    if (oldHook.listenable != hook.listenable) {
      oldHook.listenable?.removeListener(context.markNeedsBuild);
      hook.listenable?.addListener(context.markNeedsBuild);
    }
  }

  @override
  void dispose() {
    hook.listenable?.removeListener(context.markNeedsBuild);
    super.dispose();
  }

  @override
  void build() {}
}
