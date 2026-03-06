/// @docImport 'package:flutter_riverpod/flutter_riverpod.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_riverpod/src/hook_consumer_provider_container_widget.dart'
    show HookConsumerProviderContainerWidget;
import 'package:utopia_hooks_riverpod/src/hook_ref.dart';
import 'package:utopia_hooks_riverpod/utopia_hooks_riverpod.dart' show HookConsumerProviderContainerWidget;

/// Retrieves the [HookRef] from the current context.
///
/// Supported in [HookConsumer], [HookConsumerWidget], and [HookConsumerProviderContainerWidget].
HookRef useHookRef() => useProvided<HookRef>();

/// Retrieves the [HookConsumerRef] from the current context.
///
/// Only available in [HookConsumer] and [HookConsumerWidget].
/// Use [HookConsumerRef.widgetRef] to get the underlying [WidgetRef] when needed.
HookConsumerRef useHookConsumerRef() => useProvided<HookConsumerRef>();

/// Watches the [provider] and rebuilds the current [HookContext] when it changes.
///
/// Supported in [HookConsumer], [HookConsumerWidget], and [HookConsumerProviderContainerWidget].
T useRefWatch<T>(ProviderListenable<T> provider) => useProvided<HookRef>().watch(provider);

/// A [Consumer] that also allows using hooks in the passed [builder] function.
class HookConsumer extends HookConsumerWidget {
  final Widget Function(BuildContext context, HookConsumerRef ref) builder;

  const HookConsumer({required this.builder, super.key});

  @override
  Widget build(BuildContext context, HookConsumerRef ref) => builder(context, ref);
}

/// A [ConsumerWidget] that also allows using hooks in its [build] method.
abstract class HookConsumerWidget extends ConsumerStatefulWidget {
  const HookConsumerWidget({super.key});

  Widget build(BuildContext context, HookConsumerRef ref);

  @override
  @nonVirtual
  ConsumerState<ConsumerStatefulWidget> createState() => _HookConsumerState();
}

class _HookConsumerState extends ConsumerState<HookConsumerWidget>
    with DiagnosticableTreeMixin, HookContextMixin, HookContextStateMixin<HookConsumerWidget> {
  late final _hookRef = HookConsumerRef(ref);

  @override
  Widget performBuild(BuildContext context) => widget.build(context, _hookRef);

  @override
  dynamic getUnsafe(Object key, {bool? watch}) {
    if (key == HookRef || key == HookConsumerRef) return _hookRef;
    return super.getUnsafe(key, watch: watch);
  }
}
