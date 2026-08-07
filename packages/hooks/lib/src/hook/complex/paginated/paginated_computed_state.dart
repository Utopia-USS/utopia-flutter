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
  /// calling [clear] and then [refresh]).
  final Future<void> Function({bool clearCache}) refresh;

  /// Cancels any in-progress load and resets all fields to their initial state. Does
  /// not trigger a reload.
  final void Function() clear;

  /// Overrides the in-memory buffer, and optionally the next-`loadMore` cursor, in a
  /// single atomic update. The paginated "value" is the coupled `(items, cursor)` pair,
  /// so they are set together — this is the paginated analogue of
  /// `MutableComputedState.updateValue`. Intended for optimistic edit/delete on a list
  /// whose server mutation has been (or is being) confirmed.
  ///
  /// [items] receives the current buffer and returns its replacement.
  ///
  /// [cursor], when provided, receives the current next-page cursor and returns the
  /// correction (e.g. `(offset) => offset - 1` after an offset-based delete, so the next
  /// [loadMore] does not skip the element that shifted into the deleted slot). Omit it to
  /// leave the cursor untouched — safe for in-place edits and for keyset deletes
  /// (`WHERE id > cursor`), which are immune to the shift. A separate updater (rather than
  /// a nullable value) keeps "leave unchanged" unambiguous even when [C] is itself
  /// nullable (token-based pagination).
  ///
  /// Interaction with an in-flight load is asymmetric, by design:
  ///   - Without [cursor], an in-flight load is **not** cancelled: it completes and
  ///     appends its page on top of the updated buffer.
  ///   - With [cursor], any in-flight load **is** cancelled, because it captured the old
  ///     cursor when it started and on completion would overwrite the correction with its
  ///     own `nextCursor`, silently re-introducing the drift.
  ///
  /// No-op (including the [cursor] part) when [items] is currently `null` — nothing has
  /// loaded yet, so there is nothing to mutate, and writing a buffer would falsely flip
  /// [isInitialized] and race the in-flight first load.
  final void Function(
    List<T> Function(List<T> current) items, {
    C Function(C current)? cursor,
  }) updateValues;

  /// Convenience for the single-row optimistic edit: replaces the item at `index` in
  /// place via `update`. Does not touch the cursor and does not cancel an in-flight load
  /// (delegates to [updateValues] items-only). No-op when [items] is `null` or `index` is
  /// out of range.
  final void Function(int index, T Function(T current) update) updateAt;

  /// Convenience for the single-row optimistic delete: removes the item at `index`.
  ///
  /// [cursor], when provided, corrects the next-`loadMore` cursor in the same atomic
  /// update — pass `(offset) => offset - 1` for **offset/page** pagination so the next
  /// page does not skip the element that shifted into the deleted slot. Omit it for
  /// **keyset** pagination (`WHERE id > cursor`), which is immune to the shift.
  ///
  /// In-flight interaction matches [updateValues]: with [cursor] any in-flight load is
  /// cancelled (it would otherwise overwrite the correction); without it the load is left
  /// running and appends on top of the shortened buffer. No-op when [items] is `null` or
  /// `index` is out of range.
  final void Function(int index, {C Function(C current)? cursor}) deleteAt;

  const MutablePaginatedComputedState({
    required this.getItems,
    required this.getCursor,
    required this.getHasMore,
    required this.getIsLoading,
    required this.getError,
    required this.loadMore,
    required this.refresh,
    required this.clear,
    required this.updateValues,
    required this.updateAt,
    required this.deleteAt,
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
