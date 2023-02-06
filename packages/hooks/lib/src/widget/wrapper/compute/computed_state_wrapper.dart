import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/util/non_scrollable_content.dart';

class ComputedStateWrapper<E> extends StatelessWidget {
  final ComputedState<E> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext, E) builder;
  final bool keepInProgress;

  const ComputedStateWrapper({
    super.key,
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.builder,
    this.keepInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = state.valueOrNull;
    late final previousValue = state.previousValueOrNull;
    if (value != null || (keepInProgress && previousValue != null)) return builder(context, value ?? previousValue!);
    return NonScrollableContent(
      child: state.value.maybeWhen(
        failed: (_) => failedBuilder(context),
        orElse: () => inProgressBuilder(context),
      ),
    );
  }
}
