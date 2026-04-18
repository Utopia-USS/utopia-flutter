import 'package:utopia_hooks/src/hook/complex/computed/computed_state.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';

/// Result of loading a single page of paginated data.
///
/// A `null` [nextCursor] signals that no more pages are available.
class PaginatedPage<T, C> {
  final List<T> items;
  final C? nextCursor;

  const PaginatedPage({required this.items, required this.nextCursor});

  /// Convenience constructor for the final page — no more data available.
  const PaginatedPage.last({required this.items}) : nextCursor = null;
}

/// Snapshot of a paginated computation: collected [items], the state of the most
/// recent page load, and whether more pages can be loaded.
///
/// [value] reflects only the **latest** page load — `inProgress` during a `loadMore` /
/// `refresh`, `ready` when idle with data, `failed` when the last load threw,
/// `notInitialized` before the first load or after a `clear`. [items] persist across
/// consecutive page loads until [MutablePaginatedComputedState.clear] or
/// [MutablePaginatedComputedState.refresh] is called.
class PaginatedComputedState<T> with ComputedStateMixin<void> {
  final List<T> items;

  @override
  final ComputedStateValue<void> value;

  /// Whether more pages can be loaded. `false` once a page returns `nextCursor == null`.
  final bool hasMore;

  const PaginatedComputedState({required this.items, required this.value, required this.hasMore});
}

final class MutablePaginatedComputedState<T> with ComputedStateMixin<void> implements PaginatedComputedState<T> {
  final List<T> Function() getItems;
  final ComputedStateValue<void> Function() getValue;
  final bool Function() getHasMore;

  /// Loads the next page using the cursor returned by the previous page (or the initial cursor).
  ///
  /// If a load is already in progress, returns the operation in flight rather than
  /// starting a second concurrent load. No-op when [hasMore] is `false`.
  final Future<void> Function() loadMore;

  /// Cancels any in-progress load, clears [items], resets the cursor, then loads the first page.
  final Future<void> Function() refresh;

  /// Cancels any in-progress load and resets [items], [hasMore], [value], and the cursor
  /// to their initial state. Does not trigger a reload.
  final void Function() clear;

  const MutablePaginatedComputedState({
    required this.getItems,
    required this.getValue,
    required this.getHasMore,
    required this.loadMore,
    required this.refresh,
    required this.clear,
  });

  @override
  List<T> get items => getItems();

  @override
  ComputedStateValue<void> get value => getValue();

  @override
  bool get hasMore => getHasMore();
}
