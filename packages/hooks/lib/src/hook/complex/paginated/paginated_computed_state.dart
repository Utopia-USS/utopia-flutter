import 'package:utopia_hooks/src/hook/complex/computed/computed_state.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';

/// Result of loading a single page of paginated data.
///
/// [C] is the cursor type. A `null` [nextCursor] signals that no more pages are available.
/// The cursor is opaque to the hook, so it can represent any pagination scheme:
/// - offset-based: `C = int`, [nextCursor] = `offset + items.length`
/// - page-based: `C = int`, [nextCursor] = `currentPage + 1`
/// - token-based: `C = String`, [nextCursor] = server-provided continuation token
/// - keyset: `C` = the last item's sort key (e.g. `DateTime`, `ItemId`)
class PaginatedPage<T, C> {
  final List<T> items;
  final C? nextCursor;

  const PaginatedPage({required this.items, required this.nextCursor});

  /// Convenience constructor for the final page — no more data available.
  const PaginatedPage.last({required this.items}) : nextCursor = null;
}

/// Snapshot of a paginated computation: collected [items], the state of the most
/// recent page load, and paging metadata.
///
/// [value] reflects only the **latest** page load — `inProgress` during a `loadMore` /
/// `refresh`, `ready` when idle with data, `failed` when the last load threw,
/// `notInitialized` before the first load or after a `clear`. [items] persist
/// across consecutive page loads until [MutablePaginatedComputedState.clear] or
/// [MutablePaginatedComputedState.refresh] is called.
class PaginatedComputedState<T, C> with ComputedStateMixin<void> {
  final List<T> items;

  @override
  final ComputedStateValue<void> value;

  /// Whether more pages can be loaded. `false` once a page returns `nextCursor == null`.
  final bool hasMore;

  /// Cursor that will be passed to the next `loadMore` call.
  /// `null` before the first load and after reaching the end.
  final C? nextCursor;

  const PaginatedComputedState({
    required this.items,
    required this.value,
    required this.hasMore,
    required this.nextCursor,
  });
}

final class MutablePaginatedComputedState<T, C> with ComputedStateMixin<void> implements PaginatedComputedState<T, C> {
  final List<T> Function() getItems;
  final ComputedStateValue<void> Function() getValue;
  final bool Function() getHasMore;
  final C? Function() getNextCursor;

  /// Loads the next page using the current [nextCursor].
  ///
  /// If a load is already in progress, returns the operation in flight rather than
  /// starting a second concurrent load. No-op when [hasMore] is `false`.
  final Future<void> Function() loadMore;

  /// Cancels any in-progress load, clears [items] and cursor, then loads the first page.
  final Future<void> Function() refresh;

  /// Cancels any in-progress load and resets [items], [nextCursor], [hasMore], and [value]
  /// to their initial state. Does not trigger a reload.
  final void Function() clear;

  const MutablePaginatedComputedState({
    required this.getItems,
    required this.getValue,
    required this.getHasMore,
    required this.getNextCursor,
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

  @override
  C? get nextCursor => getNextCursor();
}
