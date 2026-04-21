import 'package:utopia_hooks/src/misc/has_initialized.dart';

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

/// Snapshot of a paginated computation.
///
/// [items] is `null` before the first successful load and after
/// [MutablePaginatedComputedState.clear]. Once populated, it persists across consecutive
/// `loadMore` calls, including while the next page is loading, and — when using
/// `refresh(clear: false)` — across a refresh until the first page of the new load
/// replaces it.
///
/// [cursor] is the cursor that will be passed to the next [MutablePaginatedComputedState.loadMore]
/// call. Starts at `initialCursor` and advances through values returned as `nextCursor`
/// in [PaginatedPage]. Stays at its last non-null value once the end is reached.
///
/// [isLoading] is `true` whenever any load (first page, `loadMore`, or `refresh`) is in
/// flight.
///
/// [error] holds the exception from the most recent failed load. It is cleared when the
/// next load starts.
///
/// [hasMore] is `false` once a page returns `nextCursor == null`.
class PaginatedComputedState<T, C> implements HasInitialized {
  final List<T>? items;
  final C? cursor;
  final bool hasMore;
  final bool isLoading;
  final Object? error;

  const PaginatedComputedState({
    required this.items,
    required this.cursor,
    required this.hasMore,
    required this.isLoading,
    required this.error,
  });

  @override
  bool get isInitialized => items != null;

  bool get hasError => error != null;
}

final class MutablePaginatedComputedState<T, C> implements PaginatedComputedState<T, C> {
  final List<T>? Function() getItems;
  final C Function() getCursor;
  final bool Function() getHasMore;
  final bool Function() getIsLoading;
  final Object? Function() getError;

  /// Loads the next page using [cursor].
  ///
  /// If a load is already in progress, returns the operation in flight rather than
  /// starting a second concurrent load. No-op when [hasMore] is `false`.
  final Future<void> Function() loadMore;

  /// Cancels any in-progress load, resets the cursor, [hasMore] and clears [error],
  /// then loads the first page.
  ///
  /// When `clear: false` (default), [items] stay visible and are replaced by the first
  /// page of the new load — no flicker. Intended for keys-triggered reloads and
  /// pull-to-refresh.
  ///
  /// When `clear: true`, [items] drops to `null` before the reload (equivalent to
  /// [clear] followed by [loadMore]).
  final Future<void> Function({bool clearCache}) refresh;

  /// Cancels any in-progress load and resets all fields to their initial state. Does
  /// not trigger a reload.
  final void Function() clear;

  const MutablePaginatedComputedState({
    required this.getItems,
    required this.getCursor,
    required this.getHasMore,
    required this.getIsLoading,
    required this.getError,
    required this.loadMore,
    required this.refresh,
    required this.clear,
  });

  @override
  List<T>? get items => getItems();

  @override
  C get cursor => getCursor();

  @override
  bool get hasMore => getHasMore();

  @override
  bool get isLoading => getIsLoading();

  @override
  Object? get error => getError();

  @override
  bool get isInitialized => items != null;

  @override
  bool get hasError => error != null;
}
