import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_utils/utopia_utils.dart';

mixin HookContextMixin implements HookContext {
  final _hooks = <HookState<Object?, Hook<Object?>>>[];
  final _postBuildCallbacks = <void Function()>[];
  var _index = 0;
  var _isFirstBuild = true;
  var _isDisposed = false;

  @override
  bool get mounted => !_isDisposed;

  @override
  T use<T>(Hook<T> hook) {
    if (_isFirstBuild) {
      final state = hook.createState();
      _hooks.add(state);
      _index++;
      state.hook = hook;
      state.context = this;
      state.init();
      return state.build();
    } else {
      assert(_index < _hooks.length, "Hooks have been added after first build");
      assert(_hooks[_index].hook.runtimeType == hook.runtimeType, "Hook type has changed after first build");
      final state = _hooks[_index++] as HookState<T, Hook<T>>;
      final oldHook = state.hook;
      state.hook = hook;
      state.didUpdate(oldHook);
      return state.build();
    }
  }

  @override
  void addPostBuildCallback(void Function() callback) {
    assert(_index != 0, "postBuildCallback can only be called inside build");
    _postBuildCallbacks.add(callback);
  }

  @protected
  T wrapBuild<T>(T Function() build) {
    return HookContext.stack.wrap(this, () {
      try {
        assert(_postBuildCallbacks.isEmpty, "triggerPostBuildCallbacks has not been called after the previous build");
        final result = build();
        assert(_index == _hooks.length, "Hooks have been removed during build");
        return result;
      } finally {
        _isFirstBuild = false;
        _index = 0;
      }
    });
  }

  @protected
  void disposeHooks() {
    for (final state in _hooks) {
      state.dispose();
    }
    _isDisposed = true;
  }

  @protected
  void triggerPostBuildCallbacks() {
    for (final callback in _postBuildCallbacks) {
      callback();
    }
    _postBuildCallbacks.clear();
  }
}

typedef _WaitingPredicate<R> = ({bool Function(R) predicate, Completer<void> completer});

class SimpleHookContext<R> with HookContextMixin implements Value<R> {
  final R Function() _build;
  late R _value;
  final Map<Type, Object?> _provided;
  final _waiting = <_WaitingPredicate<R>>[];

  SimpleHookContext(this._build, {Map<Type, Object?> provided = const {}}) : _provided = Map.of(provided) {
    rebuild();
  }

  @override
  R get value => _value;

  R rebuild() {
    _value = wrapBuild(_build);
    triggerPostBuildCallbacks();
    for (final entry in List.of(_waiting)) {
      if (entry.predicate(_value)) {
        _waiting.remove(entry);
        entry.completer.complete();
      }
    }
    return _value;
  }

  @override
  T get<T>() => _provided[T] as T;

  @override
  @protected
  void markNeedsBuild() => rebuild();

  void setProvided<T>(T value) {
    _provided[T] = value;
    rebuild();
  }

  Future<void> waitUntil(bool Function(R) predicate) async {
    if (predicate(_value)) return;
    final completer = Completer<void>();
    _waiting.add((predicate: predicate, completer: completer));
    await completer.future;
  }

  void dispose() => disposeHooks();
}
