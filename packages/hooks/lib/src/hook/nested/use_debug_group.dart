import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

T useDebugGroup<T>(
  T Function() block, {
  String? debugLabel,
  void Function(DiagnosticPropertiesBuilder)? debugFillProperties,
}) {
  if(kDebugMode) {
    return use(_DebugGroupHook(block, debugFillProperties, debugLabel: debugLabel));
  }
  return block();
}

final class _DebugGroupHook<T> extends Hook<T> {
  final T Function() block;
  final void Function(DiagnosticPropertiesBuilder)? _debugFillProperties;

  const _DebugGroupHook(this.block, this._debugFillProperties, {String? debugLabel})
      : super(debugLabel: debugLabel ?? "useGroup()");

  @override
  HookState<T, _DebugGroupHook<T>> createState() => _DebugGroupHookState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    _debugFillProperties?.call(properties);
  }
}

final class _DebugGroupHookState<T> extends HookState<T, _DebugGroupHook<T>>
    with DiagnosticableTreeMixin, HookStateDiagnosticableMixin<T, _DebugGroupHook<T>>, HookContextMixin {
  @override
  T build() {
    return wrapBuild(() {
      final result = hook.block();
      context.addPostBuildCallback(triggerPostBuildCallbacks);
      return result;
    });
  }

  @override
  dynamic getUnsafe(Type type) => context.getUnsafe(type);

  @override
  void markNeedsBuild() => context.markNeedsBuild();

  @override
  void dispose() {
    disposeHooks();
    super.dispose();
  }
}