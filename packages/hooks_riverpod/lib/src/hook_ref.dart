/// @docImport 'package:flutter_riverpod/flutter_riverpod.dart';
/// @docImport 'package:utopia_hooks/utopia_hooks.dart';
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_riverpod/utopia_hooks_riverpod.dart';

/// An interface over [WidgetRef] that can be used in the context of hooks.
///
/// Call [useHookRef] to retrieve it inside a hook.
/// This class implements all methods supported in [WidgetRef] and they have exactly the same semantics as in [WidgetRef].
/// The underlying [WidgetRef] isn't exposed because its methods can't be used safely in all contexts where [HookRef] is available (in [HookConsumerProviderContainerWidget]).
/// To access the underlying [WidgetRef] in contexts where it's safe to do so, use [HookConsumerRef].
sealed class HookRef implements MutationTarget {
  const HookRef(this._widgetRef);

  final WidgetRef _widgetRef;

  @override
  ProviderContainer get container => _widgetRef.container;

  T watch<T>(ProviderListenable<T> provider) => _widgetRef.watch(provider);

  T read<T>(ProviderListenable<T> provider) => _widgetRef.read(provider);

  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool weak = false,
  }) =>
      _widgetRef.listen(provider, listener, onError: onError, weak: weak);

  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
    bool weak = false,
  }) =>
      _widgetRef.listenManual(provider, listener, onError: onError, fireImmediately: fireImmediately, weak: weak);

  S refresh<S>(Refreshable<S> provider) => _widgetRef.refresh(provider);

  void invalidate(ProviderOrFamily provider, {bool asReload = false}) =>
      _widgetRef.invalidate(provider, asReload: asReload);

  bool exists(ProviderBase<Object?> provider) => _widgetRef.exists(provider);
}

/// An extended [HookRef] available in [HookConsumer] and [HookConsumerWidget].
///
/// Call [useHookConsumerRef] to retrieve it inside a hook.
/// The underlying [WidgetRef] can be safely accessed via [widgetRef].
class HookConsumerRef extends HookRef {
  const HookConsumerRef(super._widgetRef);

  /// The underlying [WidgetRef].
  ///
  /// Calling this [WidgetRef]'s methods is always safe and equivalent to calling matching [HookRef] methods.
  WidgetRef get widgetRef => _widgetRef;
}

@internal
class HookProviderRef extends HookRef {
  HookProviderRef(super._widgetRef, this._container);

  final HookProviderContainer _container;
  final _watchedProviders = <ProviderListenable<dynamic>>{};

  @override
  T watch<T>(ProviderListenable<T> provider) {
    if (!_watchedProviders.contains(provider)) {
      _watchedProviders.add(provider);
      _widgetRef.listenManual<T>(
        provider,
        (_, __) => unawaited(Future.microtask(() => _container.refresh(_container.getDependents(HookRef)))),
        fireImmediately: false,
      );
    }
    return _widgetRef.read(provider);
  }
}
