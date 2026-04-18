import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/complex/paginated/paginated_computed_state.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

/// Allows for cursor-based pagination with automatic loading of the first page and
/// refreshing on [keys] changes.
///
/// [compute] is called with the cursor to use for the next page — starting from
/// [initialCursor] and advancing through values returned as `nextCursor` in
/// [PaginatedPage]. A `null` `nextCursor` on the returned page marks the last page
/// and disables further loading until [MutablePaginatedComputedState.refresh] or
/// [keys] change.
///
/// The cursor [C] is opaque to the hook and can model any pagination scheme. See
/// examples below for offset-based, page-based, and token-based APIs.
///
/// [shouldCompute] gates all loading. When `false`, state is cleared immediately and
/// any in-progress load is cancelled. When it transitions back to `true`, the first
/// page is re-loaded.
///
/// [keys] triggers a full reset and reload from [initialCursor] on every change.
///
/// [debounceDuration] delays the first-page load after [keys] change — useful for
/// paginated search fields. Does not affect subsequent `loadMore` calls.
///
/// [deduplicate] is an optional equality comparator. When provided, items matching any
/// already-collected item are dropped before being appended. Useful when adjacent pages
/// may overlap due to concurrent writes on the backend.
///
/// ## Example: offset-based pagination
///
/// ```dart
/// usePaginatedComputedState<User, int>(
///   initialCursor: 0,
///   (offset) async {
///     final items = await api.getUsers(offset: offset, limit: 20);
///     return PaginatedPage(
///       items: items,
///       nextCursor: items.length < 20 ? null : offset + items.length,
///     );
///   },
/// );
/// ```
///
/// ## Example: page-based pagination
///
/// ```dart
/// usePaginatedComputedState<User, int>(
///   initialCursor: 1,
///   (page) async {
///     final response = await api.getUsers(page: page, pageSize: 20);
///     return PaginatedPage(
///       items: response.items,
///       nextCursor: response.hasNext ? page + 1 : null,
///     );
///   },
/// );
/// ```
///
/// ## Example: token-based pagination
///
/// For APIs where the server returns an opaque continuation token, pick a nullable
/// [C] so that `null` can represent "no token yet" on the first call:
///
/// ```dart
/// usePaginatedComputedState<User, String?>(
///   initialCursor: null,
///   (token) async {
///     final response = await api.getUsers(pageToken: token);
///     return PaginatedPage(
///       items: response.items,
///       nextCursor: response.nextPageToken,
///     );
///   },
/// );
/// ```
MutablePaginatedComputedState<T> usePaginatedComputedState<T, C>(
  Future<PaginatedPage<T, C>> Function(C cursor) compute, {
  required C initialCursor,
  bool shouldCompute = true,
  HookKeys keys = hookKeysEmpty,
  Duration debounceDuration = Duration.zero,
  bool Function(T a, T b)? deduplicate,
}) {
  return useDebugGroup(
    debugLabel: 'usePaginatedComputedState<$T, $C>()',
    debugFillProperties: (properties) => properties
      ..add(DiagnosticsProperty("shouldCompute", shouldCompute, defaultValue: true))
      ..add(IterableProperty("keys", keys, defaultValue: hookKeysEmpty))
      ..add(DiagnosticsProperty("debounceDuration", debounceDuration, defaultValue: Duration.zero))
      ..add(FlagProperty("deduplicate", value: deduplicate != null, ifTrue: "deduplicating")),
    () {
      final state = _usePaginatedComputedState(compute, initialCursor: initialCursor, deduplicate: deduplicate);
      final timerState = useState<Timer?>(null);
      final isMounted = useIsMounted();

      useEffect(() {
        state.clear();
        timerState.value?.cancel();
        timerState.value = null;
        if (shouldCompute) {
          if (debounceDuration == Duration.zero) {
            unawaited(state.loadMore());
          } else {
            timerState.value = Timer(debounceDuration, () {
              if (isMounted()) {
                unawaited(state.loadMore());
                timerState.value = null;
              }
            });
          }
        }
      }, [shouldCompute, ...keys]);

      return state;
    },
  );
}

MutablePaginatedComputedState<T> _usePaginatedComputedState<T, C>(
  Future<PaginatedPage<T, C>> Function(C cursor) compute, {
  required C initialCursor,
  bool Function(T a, T b)? deduplicate,
}) {
  final itemsState = useState<List<T>>(const [], listen: false);
  final cursorState = useState<C>(initialCursor, listen: false);
  final hasMoreState = useState<bool>(true, listen: false);
  final valueState = useState<ComputedStateValue<void>>(ComputedStateValue.notInitialized);
  final computeWrapper = useValueWrapper(compute);
  final deduplicateWrapper = useValueWrapper(deduplicate);
  final initialCursorWrapper = useValueWrapper(initialCursor);
  final isMounted = useIsMounted();

  Future<void> loadMore() {
    if (!hasMoreState.value) return Future.value();

    final inProgress = valueState.value.maybeWhen(
      inProgress: (operation) => operation,
      orElse: () => null,
    );
    if (inProgress != null) return inProgress.value;

    final cursor = cursorState.value;
    final completer = CancelableCompleter<void>();
    valueState.value = ComputedStateValue.inProgress(completer.operation);

    Future.sync(() async {
      try {
        final page = await computeWrapper.value(cursor);
        if (!completer.isCanceled && isMounted()) {
          final dedup = deduplicateWrapper.value;
          final incoming = dedup == null
              ? page.items
              : page.items.where((a) => !itemsState.value.any((b) => dedup(a, b))).toList(growable: false);
          itemsState.value = [...itemsState.value, ...incoming];
          if (page.nextCursor != null) {
            cursorState.value = page.nextCursor as C;
          } else {
            hasMoreState.value = false;
          }
          valueState.value = const ComputedStateValue<void>.ready(null);
          completer.complete(null);
        }
      } catch (e, s) {
        if (!completer.isCanceled && isMounted()) {
          valueState.value = ComputedStateValue.failed(e);
          completer.completeError(e, s);
        }
      }
    }).ignore();

    return completer.operation.value;
  }

  void clear() {
    valueState.value.maybeWhen<void>(
      inProgress: (operation) => unawaited(operation.cancel()),
      orElse: () {},
    );
    itemsState.value = const [];
    cursorState.value = initialCursorWrapper.value;
    hasMoreState.value = true;
    valueState.value = ComputedStateValue.notInitialized;
  }

  Future<void> refresh() {
    clear();
    return loadMore();
  }

  return useMemoized(
    () => MutablePaginatedComputedState<T>(
      getItems: () => itemsState.value,
      getValue: () => valueState.value,
      getHasMore: () => hasMoreState.value,
      loadMore: loadMore,
      refresh: refresh,
      clear: clear,
    ),
  );
}
