import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/hook/compute/computed_state.dart';

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
    if (state.mode == ComputedStateMode.failed) {
      return _buildNonScrollableContent(failedBuilder(context));
    } else if(state.mode == ComputedStateMode.ready) {
      if(state.value!.isNotEmpty) {
        return builder(context, state.value!);
      } else {
        return _buildNonScrollableContent(emptyBuilder(context));
      }
    } else {
      return _buildNonScrollableContent(inProgressBuilder(context));
    }
  }

  Widget _buildNonScrollableContent(Widget child) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        SingleChildScrollView(physics: AlwaysScrollableScrollPhysics()),
      ],
    );
  }
}
