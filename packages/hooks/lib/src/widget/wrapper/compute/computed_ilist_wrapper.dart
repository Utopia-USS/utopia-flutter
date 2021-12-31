import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/computed_state_wrapper.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/util/non_scrollable_content.dart';

class ComputedIListWrapper<E> extends StatelessWidget {
  final ComputedState<IList<E>> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext, IList<E>) builder;
  final bool keepInProgress;

  const ComputedIListWrapper({
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.emptyBuilder,
    required this.builder,
    this.keepInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return ComputedStateWrapper<IList<E>>(
      keepInProgress: keepInProgress,
      state: state,
      inProgressBuilder: inProgressBuilder,
      failedBuilder: failedBuilder,
      builder: (context, value) => value.isEmpty
          ? NonScrollableContent(child: emptyBuilder(context))
          : builder(context, value),
    );
  }
}
