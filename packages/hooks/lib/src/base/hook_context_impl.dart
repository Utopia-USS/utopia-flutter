import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';
import 'package:utopia_hooks/src/util/immediate_locking_scheduler.dart';
import 'package:utopia_utils/utopia_utils.dart';

/// Mixin with common parts of [HookContext] implementations.
///
/// This mixin should be used by all [HookContext] implementations.
/// Implementations should only override [HookContext.markNeedsBuild] and call [wrapBuild], [triggerPostBuildCallbacks]
/// and [disposeHooks] as needed.
mixin HookContextMixin on DiagnosticableTree implements HookContext {
  final _hooks = <HookState<Object?, Hook<Object?>>>[];
  final _postBuildCallbacks = <void Function()>[];
  var _index = 0;
  var _isFirstBuild = true;
  var _mounted = true;
  var _debugPostBuildCallbacksDirty = false;
  var _debugWillReassemble = false;

  @override
  @nonVirtual
  bool get mounted => _mounted;

  @override
  @nonVirtual
  T use<T>(Hook<T> hook) {
    if (_isFirstBuild) {
      final state = _createState(hook);
      _index++;
      _hooks.add(state);
      state.init();
      return state.build();
    } else {
      var isUpdate = true;
      assert(() {
        if (_index == _hooks.length) {
          if (_debugWillReassemble) {
            isUpdate = false;
            _hooks.add(_createState(hook));
          } else {
            throw FlutterError.fromParts([
              ErrorSummary("Trying to add a hook after the first build"),
              ErrorDescription("New hooks cannot be added after the first build"),
              ErrorHint("To dynamically change hooks during build, use control flow hooks"), // TODO add article link
              DiagnosticableNode(name: "hook", value: hook, style: null),
              DiagnosticableTreeNode(name: "context", value: this, style: null),
            ]);
          }
        }
        if (_hooks[_index].hook.runtimeType != hook.runtimeType) {
          if (_debugWillReassemble) {
            _hooks[_index].dispose();
            _hooks[_index] = _createState(hook);
            isUpdate = false;
          } else {
            throw FlutterError.fromParts([
              ErrorSummary("Trying to change hook type after the first build"),
              ErrorDescription("Hook types cannot be changed after the first build"),
              ErrorHint("To dynamically change hooks during build, use control flow hooks"), // TODO add article link
              DiagnosticableNode(name: "old hook", value: _hooks[_index].hook, style: null),
              DiagnosticableNode(name: "new hook", value: hook, style: null),
              DiagnosticableTreeNode(name: "context", value: this, style: null),
            ]);
          }
        }
        return true;
      }());
      final state = _hooks[_index++] as HookState<T, Hook<T>>;
      final oldHook = state.hook;
      state.hook = hook;
      if (isUpdate) {
        state.didUpdate(oldHook);
      } else {
        state.init();
      }
      return state.build();
    }
  }

  HookState<T, Hook<T>> _createState<T>(Hook<T> hook) {
    return hook.createState()
      ..hook = hook
      ..context = this;
  }

  @override
  @nonVirtual
  void addPostBuildCallback(void Function() callback) {
    assert(() {
      if (_index == 0) {
        throw FlutterError.fromParts([
          ErrorSummary("addPostBuildCallback can only be called during build"),
          DiagnosticableTreeNode(name: "context", value: this, style: null),
        ]);
      }
      return true;
    }());
    _postBuildCallbacks.add(callback);
  }

  /// Performs [build] in this [HookContext].
  @protected
  T wrapBuild<T>(T Function() build) {
    return HookContext.wrap(this, () {
      try {
        assert(() {
          if (_debugPostBuildCallbacksDirty) {
            throw FlutterError.fromParts([
              ErrorSummary("triggerPostBuildCallbacks has not been called after the previous build"),
              DiagnosticableTreeNode(name: "context", value: this, style: null),
            ]);
          }
          _debugPostBuildCallbacksDirty = true;
          return true;
        }());

        final result = build();

        assert(() {
          if (_index < _hooks.length) {
            if (_debugWillReassemble) {
              while (_index++ < _hooks.length) {
                _hooks.removeLast().dispose();
              }
            } else {
              throw FlutterError.fromParts([
                ErrorSummary("Hooks have been removed during build"),
                ErrorDescription("Hooks that were called during the first build must be called in every other build"),
                ErrorHint("To dynamically change hooks during build, use control flow hooks"), // TODO add article link
                DiagnosticsBlock(
                  name: "removed hooks",
                  children: _hooks.skip(_index).map((it) => it.toDiagnosticsNode()).toList(),
                ),
                DiagnosticableTreeNode(name: "context", value: this, style: null),
              ]);
            }
          }
          return true;
        }());

        return result;
      } finally {
        assert(() {
          _debugWillReassemble = false;
          return true;
        }());
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
    assert(() {
      if (!_mounted) {
        throw FlutterError.fromParts([
          ErrorSummary("disposeHooks has been called more than once"),
          ErrorDescription("disposeHooks must be called exactly once"),
          DiagnosticableTreeNode(name: "context", value: this, style: null),
        ]);
      }
      return true;
    }());

    for (final state in _hooks) {
      state.dispose();
    }
    _mounted = false;
  }

  /// Triggers all callbacks registered in the previous build.
  ///
  /// This method must be called once after every build.
  /// Implementations can decide whether call this method immediately after [wrapBuild], or schedule it for later.
  @protected
  void triggerPostBuildCallbacks() {
    assert(() {
      if (!_debugPostBuildCallbacksDirty) {
        throw FlutterError.fromParts([
          ErrorSummary("triggerPostBuildCallbacks has been called more than once"),
          ErrorDescription("triggerPostBuildCallbacks must be called exactly once after every build"),
          DiagnosticableTreeNode(name: "context", value: this, style: null),
        ]);
      }
      _debugPostBuildCallbacksDirty = false;
      return true;
    }());

    for (final callback in _postBuildCallbacks) {
      callback();
    }
    _postBuildCallbacks.clear();
  }

  @protected
  void debugMarkWillReassemble() {
    assert(() {
      _debugWillReassemble = true;
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('postBuildCallbacks', _postBuildCallbacks));
    properties.add(IntProperty('current hook index', _index));
    properties.add(FlagProperty('first build', value: _isFirstBuild, ifTrue: 'first build not completed'));
    properties.add(FlagProperty('mounted', value: _mounted, ifFalse: 'disposed'));
    properties.add(FlagProperty('has hooks', value: _hooks.isNotEmpty, ifFalse: 'no hooks'));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() => _hooks.map((it) => it.toDiagnosticsNode()).toList();
}

typedef _WaitingPredicate<R> = ({bool Function(R) predicate, Completer<void> completer});

class SimpleHookContext<R> with DiagnosticableTreeMixin, HookContextMixin implements Value<R> {
  final R Function() _build;
  late R _value;
  final Map<Type, Object?> _provided;
  final _waiting = <_WaitingPredicate<R>>[];
  bool shouldRebuild;
  var _needsBuild = false;
  final _scheduler = ImmediateLockingScheduler();

  bool get needsBuild => _needsBuild;

  SimpleHookContext(
    this._build, {
    bool init = true,
    this.shouldRebuild = true,
    Map<Type, Object?> provided = const {},
  }) : _provided = Map.of(provided) {
    if (init) _scheduler(rebuild);
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
    _needsBuild = false;
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
  void markNeedsBuild() {
    if (shouldRebuild) {
      _scheduler(rebuild);
    } else {
      _needsBuild = true;
    }
  }

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
