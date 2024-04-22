import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/flutter/hook_widget.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/base/provider/hook_provider_container.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';

/// A context in which hooks can be used.
///
/// It's strongly recommended to use [HookContextMixin] when implementing [HookContext].
abstract interface class HookContext implements ProviderContext {
  static final _stack = <HookContext>[];

  /// The currently active [HookContext].
  ///
  /// This will be not `null` iff some [HookContext] is during build.
  static HookContext? get current => _stack.lastOrNull;

  /// Runs [callback] with [context] as the current [HookContext].
  ///
  /// This method should only be used by [HookContext] implementations.
  static T wrap<T>(HookContext context, T Function() callback) {
    _stack.add(context);
    try {
      return callback();
    } finally {
      _stack.removeLast();
    }
  }

  /// Whether this [HookContext] is still valid.
  ///
  /// Usually this is `true` after the [HookContext] has been created and becomes `false` after it has been disposed.
  /// See [useIsMounted] to access this value outside the build.
  bool get mounted;

  /// Registers [hook] in this [HookContext] and returns its value.
  ///
  /// This method can only be called during build of this [HookContext], otherwise an exception will be thrown.
  /// After the first build, all subsequent builds must call this method in the same order, with [Hook]s of the same
  /// type.
  T use<T>(Hook<T> hook);

  /// Requests that this [HookContext] should be rebuilt.
  ///
  /// This method should only be called from implementations of [HookState].
  /// This method can't be called during build.
  /// Depending on the implementation, the build can be performed immediately or scheduled for later. In such case,
  /// if [markNeedsBuild] is called multiple times before the build is performed, it should be performed only once.
  void markNeedsBuild();

  /// Registers [callback] to be called after the current build.
  ///
  /// This method should only be called from implementations of [HookState].
  /// This method can only be called during build of this [HookContext], otherwise an exception will be thrown.
  /// The callbacks will be called in the order they were registered.
  void addPostBuildCallback(void Function() callback);
}

/// Register [hook] in the current [HookContext] and return its value.
///
/// Shorthand for [HookContext.use] on [HookContext.current].
/// This method can only be called during build in supported contexts (e.g. [HookWidget] or [HookProviderContainer]).
/// Calling it outside of a valid context will throw an exception.
/// After the first build, all subsequent builds must call this method in the same order, with [Hook]s of the same
/// type.
T use<T>(Hook<T> hook) {
  assert(() {
    if (HookContext.current == null) {
      throw FlutterError.fromParts([
        ErrorSummary("Tried to use() a hook without an available HookContext"),
        ErrorDescription("Hooks can only be used during builds of valid HookContexts"),
        ErrorHint("To use hooks in Widgets, use HookWidget"),
        DiagnosticableNode(name: "hook", value: hook, style: null),
      ]);
    }
    return true;
  }());
  return HookContext.current!.use(hook);
}

/// Retrieves the current [HookContext].
///
/// Shorthand for [HookContext.current].
/// This method can only be called during build in supported contexts (e.g. [HookWidget] or [HookProviderContainer]).
/// Calling it outside of a valid context will throw an exception.
/// After the first build, all subsequent builds must call this method in the same order, with [Hook]s of the same
/// type.
HookContext useContext() {
  final context = HookContext.current;
  assert(() {
    if (context == null) {
      throw FlutterError.fromParts([
        ErrorSummary("Tried to useContext() without an available HookContext"),
        ErrorDescription("useContext() can only be used during builds of valid HookContexts"),
        ErrorHint("To use hooks in Widgets, use HookWidget"),
      ]);
    }
    return true;
  }());
  return context!;
}

/// Retrieves a provided value of type [T] and registers it as a dependency of the current [HookContext].
///
/// Shorthand for [ProviderContextExtensions.get] on [HookContext.current].
/// Implementations should throw [ProvidedValueNotFoundException] when the requested value can't be provided.
T useProvided<T>() => useContext().get<T>();

/// Retrieves a provided value assigned to [type] and registers it as a dependency of the current [HookContext].
///
/// Shorthand for [ProviderContext.getUnsafe] on [HookContext.current].
/// Consider using a type-safe [useProvided] instead.
dynamic useProvidedUnsafe(Type type) => useContext().getUnsafe(type);

/// Retrieves a [BuildContext] from the current [HookContext].
///
/// Shorthand for [useProvided] with [BuildContext] as the type parameter.
/// This doesn't have to be available in every [HookContext] (e.g. when using raw [HookProviderContainer]).
/// This [BuildContext] can be used to register dependencies on [InheritedWidget]s, rebuilding the hook after it changes.
BuildContext useBuildContext() => useProvided<BuildContext>();
