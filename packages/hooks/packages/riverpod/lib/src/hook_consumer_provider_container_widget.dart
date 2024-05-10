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
    with DiagnosticableTreeMixin, HookProviderContainerWidgetStateMixin {
  @override
  Map<Type, Object Function()> get additionalProviders => {WidgetRef: () => ref};

  @override
  Widget build(BuildContext context) {
    // There's no way to listen for changes in providers watched via WidgetRef.watch so we need to rebuild its
    // dependents every build.
    // TODO Consider implementing a custom WidgetRef to track dependency changes.
    container.refresh({WidgetRef});
    return super.build(context);
  }
}
