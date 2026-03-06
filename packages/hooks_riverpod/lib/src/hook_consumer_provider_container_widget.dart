import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

import 'hook_ref.dart';

/// A version of [HookProviderContainerWidget] that allows using package:riverpod's providers in its [providers].
///
/// This widget requires [ProviderScope] to be present above it in the widget tree.
///
class HookConsumerProviderContainerWidget extends ConsumerStatefulWidget with HookProviderContainerWidgetMixin {
  @override
  final Map<Type, Object? Function()> providers;
  @override
  final bool alwaysNotifyDependents;
  @override
  final Priority schedulerPriority;
  @override
  final Widget child;

  const HookConsumerProviderContainerWidget(
    this.providers, {
    super.key,
    this.alwaysNotifyDependents = true,
    this.schedulerPriority = Priority.animation,
    required this.child,
  });

  @override
  ConsumerState<HookConsumerProviderContainerWidget> createState() => _HookConsumerProviderContainerWidgetState();
}

class _HookConsumerProviderContainerWidgetState extends ConsumerState<HookConsumerProviderContainerWidget>
    with DiagnosticableTreeMixin, HookProviderContainerWidgetStateMixin {
  late final _hookRef = HookProviderRef(ref, container!);

  @override
  Map<Type, Object Function()> get additionalProviders => {HookRef: () => _hookRef};
}
