import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
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
/// [initialCursor] is captured on first build. For dynamic starting points, wrap the
/// hook in `useKeyed` so the state is fully recreated.
///
/// [shouldCompute] gates all loading. When `false`, state is cleared (items drop to
/// `null`) and any in-progress load is cancelled. When it transitions back to `true`,
/// the first page is loaded.
///
/// [keys] triggers a refresh from [initialCursor] on every change. Items stay visible
/// until the first page of the new load replaces them — no flicker.
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
MutablePaginatedComputedState<T, C> usePaginatedComputedState<T, C>(
  Future<PaginatedPage<T, C>> Function(C cursor) compute, {
  required C initialCursor,
  bool shouldCompute = true,
  bool clearOnShouldComputeFalse = false,
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
      final isMounted = useIsMounted();

      useEffect(() {
        if (!shouldCompute) {
          if (clearOnShouldComputeFalse) state.clear();
        } else if (debounceDuration == Duration.zero) {
          unawaited(state.refresh());
        } else {
          final timer = Timer(debounceDuration, () {
            if (isMounted()) unawaited(state.refresh());
          });
          return timer.cancel;
        }
      }, [shouldCompute, ...keys]);

      return state;
    },
  );
}

MutablePaginatedComputedState<T, C> _usePaginatedComputedState<T, C>(
  Future<PaginatedPage<T, C>> Function(C cursor) compute, {
  required C initialCursor,
  bool Function(T a, T b)? deduplicate,
}) {
  final itemsState = useState<List<T>?>(null);
  final cursorState = useState<C>(initialCursor, listen: false);
  final hasMoreState = useState<bool>(true);
  final errorState = useState<Object?>(null);
  final inFlightState = useState<CancelableOperation<void>?>(null);
  final computeWrapper = useValueWrapper(compute);
  final deduplicateWrapper = useValueWrapper(deduplicate);
  final isMounted = useIsMounted();

  void cancelInFlight() {
    final inFlight = inFlightState.value;
    if (inFlight != null) unawaited(inFlight.cancel());
    inFlightState.value = null;
  }

  List<T> mergeIncoming(PaginatedPage<T, C> page, {required bool replace}) {
    if (replace) return List.of(page.items, growable: false);
    final dedup = deduplicateWrapper.value;
    final existing = itemsState.value ?? const [];
    if (dedup == null) return [...existing, ...page.items];
    final incoming = page.items.where((a) => !existing.any((b) => dedup(a, b)));
    return [...existing, ...incoming];
  }

  Future<void> load({required bool replace}) {
    if (!hasMoreState.value) return Future.value();

    final inFlight = inFlightState.value;
    if (inFlight != null) return inFlight.value;

    final cursor = cursorState.value;
    final completer = CancelableCompleter<void>();
    inFlightState.value = completer.operation;
    errorState.value = null;

    Future.sync(() async {
      try {
        final page = await computeWrapper.value(cursor);
        if (!completer.isCanceled && isMounted()) {
          itemsState.value = mergeIncoming(page, replace: replace);
          if (page.nextCursor != null) {
            cursorState.value = page.nextCursor as C;
          } else {
            hasMoreState.value = false;
          }
          inFlightState.value = null;
          completer.complete(null);
        }
      } catch (e, s) {
        if (!completer.isCanceled && isMounted()) {
          errorState.value = e;
          inFlightState.value = null;
          completer.completeError(e, s);
        }
      }
    }).ignore();

    return completer.operation.value;
  }

  void clear({bool clearCache = true}) {
    cancelInFlight();
    cursorState.value = initialCursor;
    hasMoreState.value = true;

    if (clearCache) {
      errorState.value = null;
      itemsState.value = null;
    }
  }

  Future<void> refresh({bool clearCache = false}) {
    clear(clearCache: clearCache);
    return load(replace: true);
  }

  return useMemoized(
    () => MutablePaginatedComputedState<T, C>(
      getItems: () => itemsState.value,
      getCursor: () => cursorState.value,
      getHasMore: () => hasMoreState.value,
      getIsLoading: () => inFlightState.value != null,
      getError: () => errorState.value,
      loadMore: () => load(replace: false),
      refresh: refresh,
      clear: clear,
    ),
  );
}
