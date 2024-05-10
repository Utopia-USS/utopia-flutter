import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

/// Retrieves the [WidgetRef] from the current context.
///
/// This is supported only in supported widgets like [HookConsumer] and [HookConsumerWidget].
WidgetRef useWidgetRef() => useProvided<WidgetRef>();

T useRefWatch<T>(ProviderListenable<T> provider) => useWidgetRef().watch(provider);

/// A [Consumer] that also allows using hooks in the passed [builder] function.
final class HookConsumer extends HookConsumerWidget {
  final Widget Function(BuildContext context, WidgetRef ref) builder;

  const HookConsumer({required this.builder, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(context, ref);
}

/// A [ConsumerWidget] that also allows using hooks in its [build] method.
abstract base class HookConsumerWidget extends ConsumerStatefulWidget {
  const HookConsumerWidget({super.key});

  Widget build(BuildContext context, WidgetRef ref);

  @override
  @nonVirtual
  ConsumerState<ConsumerStatefulWidget> createState() => _HookConsumerState();
}

class _HookConsumerState extends ConsumerState<HookConsumerWidget>
    with DiagnosticableTreeMixin, HookContextMixin, HookContextStateMixin<HookConsumerWidget> {
  @override
  Widget performBuild(BuildContext context) => widget.build(context, ref);

  @override
  dynamic getUnsafe(Type type) {
    if (type == WidgetRef) return ref;
    return super.getUnsafe(type);
  }
}
