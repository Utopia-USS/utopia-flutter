import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';

abstract base class NestedHookState<T, H extends Hook<T>> extends HookState<T, H> {
  final _contexts = <Object, _NestedHookContext>{};
  final _used = <Object>{};
  bool _isBuilding = false;

  T buildInner();

  @override
  @nonVirtual
  T build() {
    try {
      _isBuilding = true;
      return buildInner();
    } finally {
      _isBuilding = false;
      context.addPostBuildCallback(_postBuild);
    }
  }

  @override
  void dispose() {
    for (final context in _contexts.values) {
      context.dispose();
    }
    super.dispose();
  }

  @protected
  R wrapBuild<R>(Object key, R Function() block) {
    assert(_isBuilding, "wrapBuild can only be called during build");
    assert(!_used.contains(key), "wrapBuild has already been called with this key during this build");
    _used.add(key);
    return _contexts.putIfAbsent(key, () => _NestedHookContext(this)).wrapBuild(block);
  }

  void _markNeedsBuild() => context.markNeedsBuild();

  R _get<R>() => context.get<R>();

  void _postBuild() {
    final unused = _contexts.keys.toSet().difference(_used);
    for (final key in unused) {
      _contexts[key]!.dispose();
      _contexts.remove(key);
    }
    _used.clear();
    for(final key in _contexts.keys) {
      _contexts[key]!.triggerPostBuildCallbacks();
    }
  }
}

class _NestedHookContext with HookContextMixin {
  final NestedHookState<Object?, Hook<Object?>> _state;

  _NestedHookContext(this._state);

  @override
  T wrapBuild<T>(T Function() build) => super.wrapBuild(build);

  @override
  void triggerPostBuildCallbacks() => super.triggerPostBuildCallbacks();

  void dispose() => disposeHooks();

  @override
  void markNeedsBuild() => _state._markNeedsBuild();

  @override
  T get<T>() => _state._get<T>();
}
