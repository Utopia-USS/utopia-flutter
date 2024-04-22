import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';
import 'package:utopia_hooks/src/util/immediate_locking_scheduler.dart';

base class HookProviderContainer with DiagnosticableTreeMixin implements ProviderContext {
  final void Function(void Function()) schedule;
  final _providers = <Type, _ProviderState>{};
  final _dependents = <Type, Set<Type>>{};
  final _dirty = <Type>{};
  final _listeners = <Type, Set<void Function(Object?)>>{};
  var _isRefreshInProgress = false;

  HookProviderContainer({required this.schedule});

  void initialize(Map<Type, Object? Function()> providers) {
    for (final entry in providers.entries) {
      _providers[entry.key] = _ProviderState(this, entry.key, entry.value);
    }
    _buildDependents();
    _triggerPostBuildCallbacks();
  }

  void refresh([Set<Type>? providers]) {
    assert(() {
      if (_isRefreshInProgress) {
        throw FlutterError.fromParts([
          ErrorSummary('Cannot refresh while refresh is in progress'),
          ErrorDescription("refresh can only be called outside of a refresh cycle"),
          ErrorHint('Use addPostBuildCallback to schedule a refresh immediately after the current one'),
          DiagnosticableTreeNode(name: 'container', value: this, style: null),
        ]);
      }
      return true;
    }());
    final shouldSchedule = _dirty.isEmpty;
    _dirty.addAll(providers ?? _providers.keys);
    if (shouldSchedule) schedule(_doRefresh);
  }

  void reassemble() {
    assert(() {
      for (final provider in _providers.values) {
        provider.debugMarkWillReassemble();
      }
      _dirty.addAll(_providers.keys);
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
  dynamic getUnsafe(Type type) => _providers[type]?.value;

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

  Set<Type> getDependents(Type type) => _dependents[type] ?? {};

  void _doRefresh() {
    _isRefreshInProgress = true;
    for (final type in _providers.keys) {
      if (_dirty.contains(type)) {
        final provider = _providers[type]!;
        provider.refreshValue();
        _dirty.addAll(_dependents[type]!);
        _listeners[type]?.forEach((it) => it(provider.value));
      }
    }
    final dirty = Set.of(_dirty);
    _dirty.clear();
    _isRefreshInProgress = false;
    _triggerPostBuildCallbacks(dirty);
  }

  void _triggerPostBuildCallbacks([Set<Type>? dirty]) {
    for (final type in dirty ?? _providers.keys) {
      _providers[type]!.triggerPostBuildCallbacks();
    }
  }

  void _buildDependents() {
    for (final dependency in _providers.keys) {
      _dependents[dependency] = {
        for (final dependent in _providers.entries)
          if (dependent.value.dependencies.contains(dependency)) dependent.key
      };
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('dirty', _dirty, level: DiagnosticLevel.debug));
    properties.add(IterableProperty('has listeners for', _listeners.keys, level: DiagnosticLevel.debug));
    properties.add(
      FlagProperty(
        'refresh in progress',
        value: _isRefreshInProgress,
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
  final Map<Type, Object?> _provided;

  SimpleHookProviderContainer(
    Map<Type, Object? Function()> providers, {
    Map<Type, Object?> provided = const {},
  })  : _provided = Map.of(provided),
        super(schedule: ImmediateLockingScheduler().call) {
    schedule(() => initialize({...providers, ..._buildProviders(provided)}));
  }

  T call<T>() => get<T>();

  void setProvided<T>(T value) {
    _provided[T] = value;
    refresh(getDependents(T));
  }

  static Map<Type, Object? Function()> _buildProviders(Map<Type, Object?> provided) {
    return {
      for (final type in provided.keys) type: () => provided[type],
    };
  }
}

class _ProviderState with DiagnosticableTreeMixin, HookContextMixin {
  final HookProviderContainer container;
  final Type type;
  final Object? Function() block;
  final Set<Type> dependencies = {};
  Object? value;

  var _isCollectingDependencies = true;

  _ProviderState(this.container, this.type, this.block) {
    refreshValue();
  }

  void refreshValue() {
    value = wrapBuild(block);
    _isCollectingDependencies = false;
  }

  void dispose() => disposeHooks();

  @override
  dynamic getUnsafe(Type type) {
    assert(() {
      if (!_isCollectingDependencies && debugDoingBuild && !dependencies.contains(type)) {
        throw FlutterError.fromParts([
          ErrorSummary('Trying to register a dependency after the first build'),
          ErrorDescription('All dependencies must be registered during the first build of the provider'),
          DiagnosticsProperty("type", type),
          DiagnosticableTreeNode(name: 'provider', value: this, style: null),
          DiagnosticableTreeNode(name: 'container', value: container, style: null),
        ]);
      }
      return true;
    }());
    if (_isCollectingDependencies) dependencies.add(type);
    return container.getUnsafe(type);
  }

  @override
  void markNeedsBuild() => container.refresh({type});

  @override
  // Make available to HookProviderContainer
  void triggerPostBuildCallbacks() => super.triggerPostBuildCallbacks();

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
    properties.add(DiagnosticsProperty('type', type, level: DiagnosticLevel.debug));
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
