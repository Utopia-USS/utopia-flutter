import 'package:flutter/material.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/computed_state_wrapper.dart';

class RefreshableComputedStateWrapper<E> extends StatelessWidget {
  final RefreshableComputedState<E> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext, E) builder;
  final bool keepInProgress;

  const RefreshableComputedStateWrapper({
    Key? key,
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.builder,
    this.keepInProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await state.refresh(),
      child: ComputedStateWrapper<E>(
        state: state,
        keepInProgress: keepInProgress,
        inProgressBuilder: inProgressBuilder,
        failedBuilder: failedBuilder,
        builder: builder,
      ),
    );
  }
}
