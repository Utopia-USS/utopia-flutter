import 'package:flutter/material.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';

import 'computed_list_wrapper.dart';

@Deprecated("Use RefreshableComputedIListWrapper")
class RefreshableComputedListWrapper<E> extends StatelessWidget {
  final RefreshableComputedState<List<E>> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext, List<E>) builder;
  final bool keepInProgress;

  const RefreshableComputedListWrapper({
    Key? key,
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.emptyBuilder,
    required this.builder,
    this.keepInProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await state.refresh(),
      child: ComputedListWrapper<E>(
        state: state,
        keepInProgress: keepInProgress,
        inProgressBuilder: inProgressBuilder,
        failedBuilder: failedBuilder,
        emptyBuilder: emptyBuilder,
        builder: builder,
      ),
    );
  }
}
