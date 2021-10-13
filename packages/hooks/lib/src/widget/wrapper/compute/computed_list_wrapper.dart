import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/computed_state_wrapper.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/util/non_scrollable_content.dart';

class ComputedListWrapper<E> extends StatelessWidget {
  final ComputedState<List<E>> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext, List<E>) builder;

  const ComputedListWrapper({
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.emptyBuilder,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ComputedStateWrapper<List<E>>(
      state: state,
      inProgressBuilder: inProgressBuilder,
      failedBuilder: failedBuilder,
      builder: (context, value) => value.isEmpty
          ? NonScrollableContent(child: emptyBuilder(context))
          : builder(context, value),
    );
  }
}
