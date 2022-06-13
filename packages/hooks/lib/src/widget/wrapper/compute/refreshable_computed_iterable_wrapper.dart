import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_hooks/src/hook/compute/computed_state.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/computed_iterable_wrapper.dart';

typedef RefreshableComputedIListWrapper<E> = RefreshableComputedIterableWrapper<IList<E>>;

typedef RefreshableComputedListWrapper<E> = RefreshableComputedIterableWrapper<List<E>>;

class RefreshableComputedIterableWrapper<I extends Iterable<dynamic>> extends StatelessWidget {
  final RefreshableComputedState<I> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext) emptyBuilder;
  final Widget Function(BuildContext, I) builder;
  final bool keepInProgress;

  const RefreshableComputedIterableWrapper({
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
      child: ComputedIterableWrapper<I>(
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
