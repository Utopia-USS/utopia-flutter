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
    Key? key,
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.builder,
    this.keepInProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return state.value.when(
      notInitialized: () => NonScrollableContent(child: inProgressBuilder(context)),
      inProgress: (_, prev) => keepInProgress && prev.valueOrNull != null
          ? builder(context, prev.valueOrNull!)
          : NonScrollableContent(child: inProgressBuilder(context)),
      failed: (_) => NonScrollableContent(child: failedBuilder(context)),
      ready: (value) => builder(context, value),
    );
  }
}
