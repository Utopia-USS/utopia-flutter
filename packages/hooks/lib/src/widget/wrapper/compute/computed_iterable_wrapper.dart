import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/computed_state_wrapper.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/util/non_scrollable_content.dart';

class ComputedIterableWrapper<I extends Iterable<dynamic>> extends StatelessWidget {
  final ComputedState<I> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext, I) builder;
  final bool keepInProgress;

  const ComputedIterableWrapper({
    super.key,
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.emptyBuilder,
    required this.builder,
    this.keepInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return ComputedStateWrapper<I>(
      state: state,
      keepInProgress: keepInProgress,
      inProgressBuilder: inProgressBuilder,
      failedBuilder: failedBuilder,
      builder: (context, value) => value.isEmpty
          ? NonScrollableContent(child: emptyBuilder(context))
          : builder(context, value),
    );
  }
}
