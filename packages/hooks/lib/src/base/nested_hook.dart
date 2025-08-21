import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';

abstract class NestedHookState<T, H extends Hook<T>> extends HookState<T, H>
    with DiagnosticableTreeMixin, HookStateDiagnosticableMixin<T, H> {
  final _contexts = <HookKeysEquatable, _NestedHookContext>{};
  final _used = <HookKeysEquatable>{};

  var _debugDoingBuild = false;

  T buildInner();

  // Redeclaration to make available for _NestedHookContext.
  @override
  @protected
  @internal
  HookContext get context;

  @override
  @nonVirtual
  T build() {
    try {
      assert(() {
        _debugDoingBuild = true;
        return true;
      }());
      return buildInner();
    } finally {
      assert(() {
        _debugDoingBuild = false;
        return true;
      }());
      // TODO investigate disposing unused contexts immediately instead of post-build
      context.addPostBuildCallback(_postBuild);
    }
  }

  @protected
  R wrapBuild<R>(HookKeys keys, R Function() block) {
    assert(_debugDoingBuild, "wrapBuild can only be called during build");
    final keysEquatable = HookKeysEquatable(keys);
    assert(
      !_used.contains(keysEquatable),
      "wrapBuild has already been called with given keys ($keysEquatable during this build",
    );
    _used.add(keysEquatable);
    return _contexts.putIfAbsent(keysEquatable, () => _NestedHookContext(this)).wrapBuild(block);
  }

  @override
  void dispose() {
    for (final context in _contexts.values) {
      context.dispose();
    }
    super.dispose();
  }

  void _postBuild() {
    final unused = _contexts.keys.toSet().difference(_used);
    for (final key in unused) {
      _contexts[key]!.dispose();
      _contexts.remove(key);
    }
    _used.clear();
    for (final key in _contexts.keys) {
      _contexts[key]!.triggerPostBuildCallbacks();
    }
  }

  @override
  void debugMarkWillReassemble() {
    super.debugMarkWillReassemble();
    for (final context in _contexts.values) {
      context.debugMarkWillReassemble();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty("building", value: _debugDoingBuild, ifTrue: "building", level: DiagnosticLevel.debug));
    properties.add(IterableProperty("used context keys", _used, ifEmpty: null, level: DiagnosticLevel.debug));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() =>
      _contexts.entries.map((it) => it.value.toDiagnosticsNode(name: it.key.toString())).toList();
}

class _NestedHookContext with DiagnosticableTreeMixin, HookContextMixin {
  final NestedHookState<Object?, Hook<Object?>> _state;

  _NestedHookContext(this._state);

  @override
  T wrapBuild<T>(T Function() build);

  @override
  void triggerPostBuildCallbacks();

  void dispose() => disposeHooks();

  @override
  void debugMarkWillReassemble();

  @override
  void markNeedsBuild() => _state.context.markNeedsBuild();

  @override
  dynamic getUnsafe(Object key, {bool? watch}) => _state.context.getUnsafe(key, watch: watch);
}
