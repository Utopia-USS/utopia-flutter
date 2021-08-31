import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/hook/compute/computed_state.dart';
import 'package:utopia_hooks/widget/wrapper/compute/computed_list_wrapper.dart';

class RefreshableComputedListWrapper<E> extends StatelessWidget {
  final RefreshableComputedState<List<E>> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext, List<E>) builder;

  const RefreshableComputedListWrapper({
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.emptyBuilder,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await state.refresh(),
      child: ComputedListWrapper<E>(
        state: state,
        inProgressBuilder: inProgressBuilder,
        failedBuilder: failedBuilder,
        emptyBuilder: emptyBuilder,
        builder: builder,
      ),
    );
  }
}
