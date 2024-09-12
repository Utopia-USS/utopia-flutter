import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class HookConsumerProviderContainerWidget extends ConsumerStatefulWidget with HookProviderContainerWidgetMixin {
  @override
  final Map<Type, Object? Function()> providers;
  @override
  final Priority schedulerPriority;
  @override
  final Widget child;

  const HookConsumerProviderContainerWidget(
    this.providers, {
    super.key,
    this.schedulerPriority = Priority.animation,
    required this.child,
  });

  @override
  ConsumerState<HookConsumerProviderContainerWidget> createState() => _HookConsumerProviderContainerWidgetState();
}

class _HookConsumerProviderContainerWidgetState extends ConsumerState<HookConsumerProviderContainerWidget>
    with DiagnosticableTreeMixin, HookProviderContainerWidgetStateMixin
    implements WidgetRef {
  final _providers = <ProviderListenable<dynamic>>{};

  @override
  Map<Type, Object Function()> get additionalProviders => {WidgetRef: () => this};

  @override
  bool exists(ProviderBase<Object?> provider) => ref.exists(provider);

  @override
  void invalidate(ProviderOrFamily provider) => ref.invalidate(provider);

  @override
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    ref.listen(provider, listener, onError: onError);
  }

  @override
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return ref.listenManual(provider, listener, onError: onError, fireImmediately: fireImmediately);
  }

  @override
  T read<T>(ProviderListenable<T> provider) => ref.read(provider);

  @override
  State refresh<State>(Refreshable<State> provider) => ref.refresh(provider);

  @override
  T watch<T>(ProviderListenable<T> provider) {
    if (!_providers.contains(provider)) {
      _providers.add(provider);
      // TODO Figure out how to selectively refresh providers.
      ref.listenManual(provider, (_, __) => container.refresh({WidgetRef}));
    }
    return ref.read(provider);
  }
}
