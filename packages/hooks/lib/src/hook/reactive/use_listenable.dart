import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

void useListenable(Listenable? listenable, {bool Function()? shouldRebuild}) =>
    use(_ListenableHook(listenable, shouldRebuild));

T useValueListenable<T>(ValueListenable<T> listenable, {bool Function(T prev, T curr)? shouldRebuild}) {
  useListenable(
    listenable,
    shouldRebuild: _useShouldRebuild(getValue: () => listenable.value, shouldRebuild: shouldRebuild),
  );
  return listenable.value;
}

T useListenableValue<T>(ListenableValue<T> listenable, {bool Function(T prev, T curr)? shouldRebuild}) {
  useListenable(
    listenable,
    shouldRebuild: _useShouldRebuild(getValue: () => listenable.value, shouldRebuild: shouldRebuild),
  );
  return listenable.value;
}

bool Function() _useShouldRebuild<T>({required T Function() getValue, bool Function(T prev, T curr)? shouldRebuild}) {
  shouldRebuild ??= (prev, curr) => prev != curr;
  final prev = useState(getValue(), listen: false);
  return () {
    final value = getValue();
    final doRebuild = shouldRebuild!.call(prev.value, value);
    prev.value = value;
    return doRebuild;
  };
}

final class _ListenableHook extends Hook<void> {
  const _ListenableHook(this.listenable, this.shouldRebuild);

  final Listenable? listenable;
  final bool Function()? shouldRebuild;

  @override
  _ListenableHookState createState() => _ListenableHookState();
}

final class _ListenableHookState extends HookState<void, _ListenableHook> {
  @override
  void init() {
    super.init();
    hook.listenable?.addListener(_listener);
  }

  @override
  void didUpdate(_ListenableHook oldHook) {
    super.didUpdate(oldHook);
    if (oldHook.listenable != hook.listenable) {
      oldHook.listenable?.removeListener(_listener);
      hook.listenable?.addListener(_listener);
    }
  }

  @override
  void dispose() {
    hook.listenable?.removeListener(_listener);
    super.dispose();
  }

  @override
  void build() {}

  void _listener() {
    if (hook.shouldRebuild?.call() ?? true) {
      context.markNeedsBuild();
    }
  }
}
