import 'dart:async';

import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';
import 'package:utopia_hooks/src/util/immediate_locking_scheduler.dart';

base class HookProviderContainer implements ProviderContext {
  final void Function(void Function()) schedule;
  final _providers = <Type, _ProviderState>{};
  final _dependents = <Type, Set<Type>>{};
  final _dirty = <Type>{};
  final _listeners = <Type, Set<void Function(Object?)>>{};
  var _isRefreshInProgress = false;

  HookProviderContainer(Map<Type, Object? Function()> providers, {required this.schedule}) {
    for (final entry in providers.entries) {
      _providers[entry.key] = _ProviderState(this, entry.key, entry.value);
    }

    for (final dependency in _providers.keys) {
      _dependents[dependency] = {
        for (final dependent in _providers.entries)
          if (dependent.value.dependencies.contains(dependency)) dependent.key
      };
    }

    schedule(_triggerPostBuildCallbacks);
  }

  void refresh([Set<Type>? providers]) {
    if (_isRefreshInProgress) throw StateError('Cannot refresh while refresh is in progress');
    final shouldSchedule = _dirty.isEmpty;
    _dirty.addAll(providers ?? _providers.keys);
    if (shouldSchedule) schedule(_doRefresh);
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
        if (provider.refreshValue()) {
          _dirty.addAll(_dependents[type]!);
          _listeners[type]?.forEach((it) => it(provider.value));
        }
      }
    }
    _dirty.clear();
    _isRefreshInProgress = false;
    _triggerPostBuildCallbacks();
  }

  void _triggerPostBuildCallbacks() {
    for (final values in _providers.values) {
      values.triggerPostBuildCallbacks();
    }
  }
}

final class SimpleHookProviderContainer extends HookProviderContainer {
  final Map<Type, Object?> _provided;

  SimpleHookProviderContainer(
    Map<Type, Object? Function()> providers, {
    Map<Type, Object?> provided = const {},
  })  : _provided = Map.of(provided),
        super({..._buildProviders(provided), ...providers}, schedule: ImmediateLockingScheduler());

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

class _ProviderState with HookContextMixin {
  final HookProviderContainer container;
  final Type type;
  final Object? Function() block;
  final Set<Type> dependencies = {};
  bool isCollectingDependencies = true;
  late Object? value;

  _ProviderState(this.container, this.type, this.block) {
    value = wrapBuild(block);
    isCollectingDependencies = false;
  }

  bool refreshValue() {
    final oldValue = value;
    value = wrapBuild(block);
    return oldValue != value;
  }

  void dispose() => disposeHooks();

  @override
  dynamic getUnsafe(Type type) {
    if (isCollectingDependencies) dependencies.add(type);
    return container.getUnsafe(type);
  }

  @override
  void markNeedsBuild() => container.refresh({type});

  @override
  // Make available to HookProviderContainer
  void triggerPostBuildCallbacks() => super.triggerPostBuildCallbacks();
}
