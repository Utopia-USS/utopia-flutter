import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utopia_hooks/src/hook/complex/paginated/paginated_computed_state.dart';

/// Convenience wrapper around [MutablePaginatedComputedState] that adds
/// pull-to-refresh and auto-triggers [MutablePaginatedComputedState.loadMore]
/// when the scrollable rendered by [builder] nears its end.
///
/// [builder] receives the current items (`null` until the first successful
/// load) and a `loadingMore` flag set while a follow-up load (loadMore or
/// refresh) is in flight on top of visible items. The caller owns all
/// rendering — empty, error, and loading indicators are derived from items
/// and [MutablePaginatedComputedState.error].
///
/// [builder] must return a scrollable for [loadMoreThreshold] detection to fire.
class PaginatedComputedStateWrapper<T, C> extends StatelessWidget {
  final MutablePaginatedComputedState<T, C> state;
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(BuildContext context, List<T>? items, bool loadingMore) builder;
  final bool refreshable;
  final double loadMoreThreshold;

  const PaginatedComputedStateWrapper({
    super.key,
    required this.state,
    required this.builder,
    this.refreshable = true,
    this.loadMoreThreshold = 200,
  });

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: builder(context, state.items, state.items != null && state.isLoading),
    );
    if (!refreshable) return child;
    return RefreshIndicator(onRefresh: state.refresh, child: child);
  }

  bool _onScroll(ScrollNotification info) {
    final items = state.items;
    if (items == null || items.isEmpty) return false;
    if (info.metrics.extentAfter < loadMoreThreshold &&
        state.hasMore &&
        !state.isLoading &&
        !state.hasError) {
      unawaited(state.loadMore());
    }
    return false;
  }
}
