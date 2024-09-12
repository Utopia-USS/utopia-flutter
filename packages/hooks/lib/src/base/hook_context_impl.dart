import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';

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
  var _debugDoingBuild = false;

  @override
  @nonVirtual
  bool get mounted => _mounted;

  @internal
  bool get debugDoingBuild => _debugDoingBuild;

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
      if (!debugDoingBuild) {
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
          _debugDoingBuild = true;
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
          _debugDoingBuild = false;
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
  /// This method must be called once after every build, even if the build threw an exception.
  /// Implementations can decide whether call this method immediately after [wrapBuild], or schedule it for later.
  /// This method will catch any exceptions thrown by the callbacks.
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
      try {
        callback();
      } catch (e, s) {
        final error = FlutterErrorDetails(
          exception: e,
          stack: s,
          library: 'utopia_hooks',
          context: DiagnosticsBlock(
            children: [
              ErrorSummary("Exception thrown by a post-build callback"),
              DiagnosticsProperty("callback", callback),
              DiagnosticableTreeNode(name: "context", value: this, style: null),
            ],
          ),
        );
        FlutterError.reportError(error);
      }
    }
    _postBuildCallbacks.clear();
  }

  /// Marks the next build as a reassemble, allowing hooks to be added or removed.
  ///
  /// This doesn't have any effect in release mode.
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
    properties.add(IterableProperty('postBuildCallbacks', _postBuildCallbacks, level: DiagnosticLevel.fine));
    properties.add(IntProperty('current hook index', _index, level: DiagnosticLevel.debug));
    properties.add(
      FlagProperty(
        'first build',
        value: _isFirstBuild,
        ifTrue: 'first build not completed',
        level: DiagnosticLevel.debug,
      ),
    );
    properties.add(FlagProperty('mounted', value: _mounted, ifFalse: 'disposed'));
    properties.add(FlagProperty('has hooks', value: _hooks.isNotEmpty, ifFalse: 'no hooks'));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() => _hooks.map((it) => it.toDiagnosticsNode()).toList();
}
