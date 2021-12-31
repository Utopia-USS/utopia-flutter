import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/computed_ilist_wrapper.dart';

class RefreshableComputedIListWrapper<E> extends StatelessWidget {
  final RefreshableComputedState<IList<E>> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext, IList<E>) builder;
  final bool keepInProgress;

  const RefreshableComputedIListWrapper({
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.emptyBuilder,
    required this.builder,
    this.keepInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await state.refresh(),
      child: ComputedIListWrapper<E>(
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
