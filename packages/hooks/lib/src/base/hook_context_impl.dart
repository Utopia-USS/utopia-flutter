import 'dart:async';

import 'package:meta/meta.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';
import 'package:utopia_utils/utopia_utils.dart';

/// Mixin with common parts of [HookContext] implementations.
///
/// This mixin should be used by all [HookContext] implementations.
/// Implementations should only override [HookContext.markNeedsBuild] and call [wrapBuild], [triggerPostBuildCallbacks]
/// and [disposeHooks] as needed.
mixin HookContextMixin implements HookContext {
  final _hooks = <HookState<Object?, Hook<Object?>>>[];
  final _postBuildCallbacks = <void Function()>[];
  var _index = 0;
  var _isFirstBuild = true;
  var _isDisposed = false;

  @override
  @nonVirtual
  bool get mounted => !_isDisposed;

  @override
  @nonVirtual
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
  @nonVirtual
  void addPostBuildCallback(void Function() callback) {
    assert(_index != 0, "postBuildCallback can only be called inside build");
    _postBuildCallbacks.add(callback);
  }

  /// Performs [build] in this [HookContext].
  @protected
  T wrapBuild<T>(T Function() build) {
    return HookContext.wrap(this, () {
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

  /// Disposes all hooks in this [HookContext] and marks is as unmounted.
  ///
  /// Should be called only once, when the [HookContext] is disposed.
  @protected
  void disposeHooks() {
    for (final state in _hooks) {
      state.dispose();
    }
    _isDisposed = true;
  }

  /// Triggers all callbacks registered in the previous build.
  ///
  /// This method must be called once after every build.
  /// Implementations can decide whether call this method immediately after [wrapBuild], or schedule it for later.
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

  SimpleHookContext(
    this._build, {
    bool init = true,
    Map<Type, Object?> provided = const {},
  }) : _provided = Map.of(provided) {
    if(init) rebuild();
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
  @protected
  dynamic getUnsafe(Type type) {
    if (!_provided.containsKey(type)) throw ProvidedValueNotFoundException(type: type, context: this);
    return _provided[type];
  }

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
