import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';

abstract class SingleNestedHookState<T, H extends KeyedHook<T>> extends NestedHookState<T, H>
    with KeyedHookStateMixin<T, H> {
  late var _nestedContext = NestedHookContext(context);

  @override
  Iterable<NestedHookContext> get nestedContexts => [_nestedContext];

  T buildNested();

  @override
  @nonVirtual
  T buildInner() => _nestedContext.wrapBuild(buildNested);

  @override
  void didUpdateKeys() {
    super.didUpdateKeys();
    _nestedContext.dispose();
    _nestedContext = NestedHookContext(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticableTreeNode(
          name: "nested context", value: _nestedContext, style: DiagnosticsTreeStyle.truncateChildren),
    );
  }
}

abstract class MultiNestedHookState<T, H extends Hook<T>> extends NestedHookState<T, H>
    with DiagnosticableTreeMixin, HookStateDiagnosticableMixin<T, H> {
  final _contexts = <HookKeysEquatable, NestedHookContext>{};
  final _used = <HookKeysEquatable>{};

  @override
  Iterable<NestedHookContext> get nestedContexts => _contexts.values;

  @protected
  R wrapBuild<R>(HookKeys keys, R Function() block) {
    assert(debugDoingBuild, "wrapBuild can only be called during build");
    final keysEquatable = HookKeysEquatable(keys);
    assert(
      !_used.contains(keysEquatable),
      "wrapBuild has already been called with given keys ($keysEquatable) during this build",
    );
    _used.add(keysEquatable);
    return _contexts.putIfAbsent(keysEquatable, () => NestedHookContext(context)).wrapBuild(block);
  }

  @override
  @protected
  void postBuild() {
    final unused = _contexts.keys.toSet().difference(_used);
    for (final key in unused) {
      _contexts[key]!.dispose();
      _contexts.remove(key);
    }
    _used.clear();
    super.postBuild();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty("used context keys", _used, ifEmpty: null, level: DiagnosticLevel.debug));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() =>
      _contexts.entries.map((it) => it.value.toDiagnosticsNode(name: it.key.toString())).toList();
}

abstract class NestedHookState<T, H extends Hook<T>> extends HookState<T, H> {
  @protected
  bool debugDoingBuild = false;

  T buildInner();

  @protected
  Iterable<NestedHookContext> get nestedContexts;

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
        debugDoingBuild = true;
        return true;
      }());
      return buildInner();
    } finally {
      assert(() {
        debugDoingBuild = false;
        return true;
      }());
      // TODO investigate disposing unused contexts immediately instead of post-build
      context.addPostBuildCallback(postBuild);
    }
  }

  @override
  void dispose() {
    for (final context in nestedContexts) {
      context.dispose();
    }
    super.dispose();
  }

  @protected
  void postBuild() {
    for (final context in nestedContexts) {
      context.triggerPostBuildCallbacks();
    }
  }

  @override
  void debugMarkWillReassemble() {
    super.debugMarkWillReassemble();
    for (final context in nestedContexts) {
      context.debugMarkWillReassemble();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty("building", value: debugDoingBuild, ifTrue: "building", level: DiagnosticLevel.debug));
  }
}

class NestedHookContext with DiagnosticableTreeMixin, HookContextMixin {
  final HookContext parent;

  NestedHookContext(this.parent);

  @override
  @internal
  T wrapBuild<T>(T Function() build);

  @override
  @internal
  void triggerPostBuildCallbacks();

  void dispose() => disposeHooks();

  @override
  @internal
  void debugMarkWillReassemble();

  @override
  void markNeedsBuild() => parent.markNeedsBuild();

  @override
  dynamic getUnsafe(Object key, {bool? watch}) => parent.getUnsafe(key, watch: watch);
}
