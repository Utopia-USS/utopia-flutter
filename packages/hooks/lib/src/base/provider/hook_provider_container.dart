import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';
import 'package:utopia_hooks/src/util/immediate_locking_scheduler.dart';

class HookProviderContainer with DiagnosticableTreeMixin implements ProviderContext {
  final void Function(void Function()) schedule;
  final bool alwaysNotifyDependents;
  final _providers = <Object, _ProviderState>{};
  final _dependents = <Object, Set<Object>>{};
  final _dirtyKeys = <Object>{};
  final _listeners = <Object, Set<void Function(Object?)>>{};

  var _debugDoingRefresh = false;

  @internal
  bool get debugDoingRefresh => _debugDoingRefresh;

  HookProviderContainer({required this.schedule, this.alwaysNotifyDependents = true});

  void initialize(Map<Object, Object? Function()> providers) {
    for (final entry in providers.entries) {
      _providers[entry.key] = _ProviderState(this, entry.key, entry.value);
    }
    _buildDependents();
    _triggerPostBuildCallbacks();
  }

  void refresh([Set<Object>? keys]) {
    assert(() {
      if (_debugDoingRefresh) {
        throw FlutterError.fromParts([
          ErrorSummary('Cannot refresh while refresh is in progress'),
          ErrorDescription("refresh can only be called outside of a refresh cycle"),
          ErrorHint('Use addPostBuildCallback to schedule a refresh immediately after the current one'),
          if (keys != null) IterableProperty('keys', keys) else MessageProperty('keys', 'all keys'),
          DiagnosticableTreeNode(name: 'container', value: this, style: DiagnosticsTreeStyle.truncateChildren),
        ]);
      }
      return true;
    }());
    final shouldSchedule = _dirtyKeys.isEmpty;
    _dirtyKeys.addAll(keys ?? _providers.keys);
    if (shouldSchedule) schedule(_doRefresh);
  }

  void reassemble() {
    assert(() {
      for (final provider in _providers.values) {
        provider.debugMarkWillReassemble();
      }
      _dirtyKeys.addAll(_providers.keys);
      _doRefresh();
      _buildDependents();
      return true;
    }());
  }

  void dispose() {
    for (final provider in _providers.values.toList().reversed) {
      provider.dispose();
    }
  }

  @override
  dynamic getUnsafe(Object key, {bool? watch}) {
    assert(watch != true, "Watching a dependency is not supported in HookProviderContainer.getUnsafe()");
    if (!_providers.containsKey(key)) return ProviderContext.valueNotFound;
    final value = _providers[key]?.value;
    assert(() {
      if (value == const _ProviderNotBuiltSentinel()) {
        throw FlutterError.fromParts([
          ErrorSummary("Provider not built yet"),
          ErrorDescription("Value of the requested provider haven't been built yet"),
          ErrorHint(
            "This can happen if all previous builds of this provider have failed. "
            "Fix the issue in the offending provider.",
          ),
          DiagnosticsProperty("key", key),
          DiagnosticableTreeNode(name: 'container', value: this, style: DiagnosticsTreeStyle.truncateChildren),
        ]);
      }
      return true;
    }());
    return value;
  }

  void Function() addListener<T>(void Function(T) listener) => addListenerUnsafe(T, (it) => listener(it as T));

  void Function() addListenerUnsafe(Type type, void Function(Object?) listener) {
    _listeners[type] ??= {};
    _listeners[type]!.add(listener);
    return () => _listeners[type]?.remove(listener);
  }

  Future<T> waitUntil<T>(bool Function(T) predicate) async =>
      (await waitUntilUnsafe(T, (it) => predicate(it as T))) as T;

  Future<Object?> waitUntilUnsafe(Type type, bool Function(Object?) predicate) async {
    final currentValue = getUnsafe(type);
    if (predicate(currentValue)) return currentValue;
    final completer = Completer<Object?>();
    final cancel = addListenerUnsafe(type, (value) {
      if (predicate(value)) completer.complete(value);
    });
    final value = await completer.future;
    cancel();
    return value;
  }

  Set<Object> getDependents(Object key) => _dependents[key] ?? {};

  void _doRefresh() {
    try {
      assert(() {
        _debugDoingRefresh = true;
        return true;
      }());
      for (final key in _providers.keys) {
        if (_dirtyKeys.contains(key)) {
          final provider = _providers[key]!;
          if (provider.refreshValue()) {
            _dirtyKeys.addAll(getDependents(key));
            _listeners[key]?.forEach((it) => it(provider.value));
          }
        }
      }
    } finally {
      assert(() {
        _debugDoingRefresh = false;
        return true;
      }());
      final dirty = Set.of(_dirtyKeys);
      _dirtyKeys.clear();
      _triggerPostBuildCallbacks(dirty);
    }
  }

  void _triggerPostBuildCallbacks([Set<Object>? keys]) {
    for (final key in keys ?? _providers.keys) {
      _providers[key]!.triggerPostBuildCallbacks();
    }
  }

  void _buildDependents() {
    _dependents.clear();
    for (final entry in _providers.entries) {
      for (final dependency in entry.value.dependencies) {
        _dependents[dependency] ??= {};
        _dependents[dependency]!.add(entry.key);
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('dirty', _dirtyKeys, level: DiagnosticLevel.debug));
    properties.add(IterableProperty('has listeners for', _listeners.keys, level: DiagnosticLevel.debug));
    properties.add(
      FlagProperty(
        'refresh in progress',
        value: _debugDoingRefresh,
        ifTrue: 'refresh in progress',
        level: DiagnosticLevel.debug,
      ),
    );
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() =>
      _providers.entries.map((it) => it.value.toDiagnosticsNode(name: it.key.toString())).toList();
}

final class SimpleHookProviderContainer extends HookProviderContainer {
  final Map<Object, Object?> _provided;

  SimpleHookProviderContainer(
    Map<Object, Object? Function()> providers, {
    Map<Object, Object?> provided = const {},
  })  : _provided = Map.of(provided),
        super(schedule: ImmediateLockingScheduler().call) {
    schedule(() => initialize(providers));
  }

  T call<T>() => get<T>();

  void setProvidedUnsafe(Object key, Object? value) {
    _provided[key] = value;
    refresh(getDependents(key));
  }

  void setProvided<T>(T value) => setProvidedUnsafe(T, value);

  @override
  dynamic getUnsafe(Object key, {bool? watch}) {
    var value = super.getUnsafe(key, watch: watch);
    if (value == ProviderContext.valueNotFound && _provided.containsKey(key)) value = _provided[key];
    return value;
  }
}

class _ProviderState with DiagnosticableTreeMixin, HookContextMixin {
  final HookProviderContainer container;
  final Object key;
  final Object? Function() block;
  final Set<Object> dependencies = {};
  Object? value = const _ProviderNotBuiltSentinel();

  var _isCollectingDependencies = true;

  _ProviderState(this.container, this.key, this.block) {
    refreshValue();
    _isCollectingDependencies = false;
  }

  bool refreshValue() {
    try {
      final oldValue = value;
      value = wrapBuild(block);
      return container.alwaysNotifyDependents || value != oldValue;
    } catch (e, s) {
      final error = FlutterErrorDetails(
        exception: e,
        stack: s,
        library: 'utopia_hooks',
        context: ErrorDescription("while building a provider"),
        informationCollector: () => [
          DiagnosticsProperty("key", key),
          DiagnosticableTreeNode(name: 'provider', value: this, style: DiagnosticsTreeStyle.truncateChildren),
          DiagnosticableTreeNode(name: 'container', value: container, style: DiagnosticsTreeStyle.truncateChildren),
        ],
      );
      FlutterError.reportError(error);
      return false;
    } finally {
      assert(() {
        _isCollectingDependencies = false;
        return true;
      }());
    }
  }

  void dispose() => disposeHooks();

  @override
  dynamic getUnsafe(Object key, {bool? watch}) {
    watch ??= _isCollectingDependencies;
    assert(() {
      if (watch! && !_isCollectingDependencies && debugDoingBuild && !dependencies.contains(key)) {
        throw FlutterError.fromParts([
          ErrorSummary('Trying to register a dependency after the first build'),
          ErrorDescription('All dependencies must be registered during the first build of the provider'),
          DiagnosticsProperty("key", key),
          DiagnosticableTreeNode(name: 'provider', value: this, style: DiagnosticsTreeStyle.truncateChildren),
          DiagnosticableTreeNode(name: 'container', value: container, style: DiagnosticsTreeStyle.truncateChildren),
        ]);
      }
      return true;
    }());
    if (watch && _isCollectingDependencies) dependencies.add(key);
    return container.getUnsafe(key);
  }

  @override
  void markNeedsBuild() => container.refresh({key});

  @override
  // Make available to HookProviderContainer
  void triggerPostBuildCallbacks();

  @override
  void debugMarkWillReassemble() {
    super.debugMarkWillReassemble();
    assert(() {
      dependencies.clear();
      _isCollectingDependencies = true;
      return true;
    }());
  }

  @override
  String toStringShort() {
    return switch (value) {
      final Diagnosticable value => value.toStringShort(),
      _ => describeIdentity(value),
    };
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('key', key, level: DiagnosticLevel.debug));
    properties.add(IterableProperty('dependencies', dependencies));
    properties.add(
      FlagProperty(
        'collecting dependencies',
        value: _isCollectingDependencies,
        ifTrue: 'collecting dependencies',
        level: DiagnosticLevel.debug,
      ),
    );
    properties.add(DiagnosticsProperty('value', value));
  }
}

class _ProviderNotBuiltSentinel {
  @literal
  const _ProviderNotBuiltSentinel();

  @override
  String toString() => "Provider not built";
}
