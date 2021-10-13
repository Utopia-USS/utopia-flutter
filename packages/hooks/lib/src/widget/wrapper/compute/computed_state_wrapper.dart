import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/util/non_scrollable_content.dart';

class ComputedStateWrapper<E> extends StatelessWidget {
  final ComputedState<E> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext, E) builder;

  const ComputedStateWrapper({
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return state.value.maybeWhen(
      failed: (_) => NonScrollableContent(child: failedBuilder(context)),
      ready: (value) => builder(context, value),
      orElse: () => NonScrollableContent(child: inProgressBuilder(context)),
    );
  }
}

