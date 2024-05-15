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
  H get hook;
}

/// Long-lived object representing entirety of the internal state of a [Hook].
abstract class HookState<T, H extends Hook<T>>
    with Diagnosticable, HookStateDiagnosticableMixin<T, H>
    implements _HookStateBase<T, H> {
  /// The current [Hook] of this [HookState].
  ///
  /// This will be set at creation of the [HookState] and updated to a new instance of [Hook] every build.
  /// This should only be set by implementations of [HookContext].
  @override
  late H hook;

  /// The [HookContext] in which this [HookState] is used.
  ///
  /// This will be set once at creation of the [HookState].
  /// This should only be set by implementations of [HookContext].
  late final HookContext context;

  /// Initialize this [HookState].
  ///
  /// Implementations can place required initialization logic in this method.
  /// This will be called only once, before the first build.
  @mustCallSuper
  void init() {}

  /// Cleanup this [HookState].
  ///
  /// Implementations can place required cleanup logic in this method.
  /// This will be called only once, when the [HookContext] is disposed.
  @mustCallSuper
  void dispose() {}

  /// Prepare this [HookState] for a build with new [hook].
  ///
  /// This will be called before every build, except the first one.
  /// [oldHook] will be the [Hook] used during the previous build.
  @mustCallSuper
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
}

/// A mixin that provides default implementation for [Diagnosticable] for [HookState].
///
/// This mixin can be used in [HookContext] implementations that somehow have the default implementation overrode.
/// See [useDebugGroup] for an example case when this mixin is needed.
mixin HookStateDiagnosticableMixin<T, H extends Hook<T>> on Diagnosticable implements _HookStateBase<T, H> {
  // Given HookState should be uniquely identified by its Hook
  @override
  @nonVirtual
  String toStringShort() => hook.toStringShort();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // Hook and its state are inherently linked, so there's no need to introduce additional nesting level
    hook.debugFillProperties(properties);
  }
}
