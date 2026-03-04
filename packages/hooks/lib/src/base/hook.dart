/// @docImport 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';

/// A definition of a hook that can be used inside a [HookContext] via [use].
abstract class Hook<T> with Diagnosticable {
  final String? _debugLabel;

  const Hook({String? debugLabel}) : _debugLabel = debugLabel;

  /// Called when [HookState] of this [Hook] needs to be created.
  ///
  /// This will be called only during the first build.
  HookState<T, Hook<T>> createState();

  @override
  @nonVirtual
  String toStringShort() => _debugLabel ?? super.toStringShort();
}

abstract class _HookStateBase<T, H extends Hook<T>> {
  bool get mounted;

  H get hook;
}

/// Long-lived object representing entirety of the internal state of a [Hook].
abstract class HookState<T, H extends Hook<T>>
    with Diagnosticable, HookStateDiagnosticableMixin<T, H>
    implements _HookStateBase<T, H> {
  H? _hook;
  HookContext? _context;

  /// Whether this [HookState] is currently mounted to a [HookContext].
  ///
  /// This will return `true` only between [init] and [dispose] calls.
  @override
  bool get mounted => _context != null;

  /// The current [Hook] of this [HookState].
  ///
  /// This is available only when [mounted]; calling will otherwise result in an error.
  /// This is updated with a new [Hook] before [didUpdate] & [build] calls.
  @override
  H get hook {
    assert(() {
      _debugCheckMounted(property: "HookState.hook");
      return true;
    }());
    return _hook!;
  }

  /// The [HookContext] in which this [HookState] is used.
  ///
  /// This is available only when [mounted]; calling will otherwise result in an error.
  HookContext get context {
    assert(() {
      _debugCheckMounted(property: "HookState.context");
      return true;
    }());
    return _context!;
  }

  @internal
  @nonVirtual
  void mount(HookContext context, H hook) {
    _context = context;
    _hook = hook;
    init();
  }

  @internal
  @nonVirtual
  void update(H hook) {
    if (hook == _hook) return;
    final oldHook = _hook!;
    _hook = hook;
    didUpdate(oldHook);
  }

  @internal
  @nonVirtual
  void unmount() {
    dispose();
    _hook = null;
    _context = null;
  }

  /// Initialize this [HookState].
  ///
  /// Implementations can place required initialization logic in this method.
  /// This will be called only once, before the first build.
  @mustCallSuper
  @protected
  void init() {}

  /// Cleanup this [HookState].
  ///
  /// Implementations can place required cleanup logic in this method.
  /// This will be called only once, when the [HookContext] is disposed.
  @mustCallSuper
  @protected
  void dispose() {}

  /// Prepare this [HookState] for a build with new [hook].
  ///
  /// This will be called before every build, except the first one.
  /// [oldHook] will be the [Hook] used during the previous build.
  @mustCallSuper
  @protected
  void didUpdate(H oldHook) {}

  /// Build the current value of this [HookState].
  ///
  /// This is the only method that is required to be overrode by the implementations.
  /// This will be called exactly once every build.
  T build();

  /// Signals that the next build will be a reassemble.
  ///
  /// This method won't be called in release mode.
  @mustCallSuper
  void debugMarkWillReassemble() {}

  void _debugCheckMounted({required String property}) {
    assert(() {
      if (!mounted) {
        throw FlutterError.fromParts(
            [ErrorSummary("Tried to access $property after it's been unmounted"), ErrorDescription("$property ")]);
      }
      return true;
    }());
  }
}

/// A mixin that provides default implementation for [Diagnosticable] for [HookState].
///
/// This mixin can be used in [HookContext] implementations that somehow have the default implementation overrode.
/// See [useDebugGroup] for an example case when this mixin is needed.
mixin HookStateDiagnosticableMixin<T, H extends Hook<T>> on Diagnosticable implements _HookStateBase<T, H> {
  // Given HookState should be uniquely identified by its Hook
  @override
  @nonVirtual
  String toStringShort() {
    if (mounted) {
      return hook.toStringShort();
    } else {
      return "<unmounted> ${describeIdentity(this)}";
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty("mounted", value: mounted, ifTrue: "mounted", ifFalse: "unmounted"));
    if (mounted) {
      // Hook and its state are inherently linked, so there's no need to introduce additional nesting level
      hook.debugFillProperties(properties);
    }
  }
}
