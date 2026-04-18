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

/// Paginated counterpart of `useComputedState` — exposes incremental loading without
/// auto-triggering the first page. Prefer [usePaginatedComputedState] for typical usage.
MutablePaginatedComputedState<T, C> usePaginatedComputedStateBase<T, C>(
  Future<PaginatedPage<T, C>> Function(C? cursor) compute, {
  bool Function(T a, T b)? deduplicate,
}) =>
    useDebugGroup(
      debugLabel: 'usePaginatedComputedStateBase<$T, $C>()',
      () => _usePaginatedComputedState(compute, deduplicate: deduplicate),
    );

/// Allows for cursor-based pagination with automatic loading of the first page and
/// refreshing on [keys] changes.
///
/// [compute] is called with the cursor of the next page to load (`null` for the first
/// page) and must return a [PaginatedPage] with the loaded items and the cursor of
/// the page after it. A `null` `nextCursor` marks the last page.
///
/// The cursor is opaque to the hook, so [compute] can implement any pagination scheme:
/// offset-based, page-based, token-based, or keyset. See [PaginatedPage] for mappings.
///
/// [shouldCompute] gates all loading. When `false`, state is cleared immediately and
/// any in-progress load is cancelled. When it transitions back to `true`, the first
/// page is re-loaded.
///
/// [keys] triggers a full reset and reload from the first page on every change.
///
/// [debounceDuration] delays the first-page load after [keys] change — useful for
/// search fields. Does not affect subsequent `loadMore` calls.
///
/// [deduplicate] is an optional equality comparator. When provided, items matching any
/// already-collected item are dropped before being appended. Useful when adjacent pages
/// may overlap due to concurrent writes on the backend.
MutablePaginatedComputedState<T, C> usePaginatedComputedState<T, C>(
  Future<PaginatedPage<T, C>> Function(C? cursor) compute, {
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
      final state = _usePaginatedComputedState(compute, deduplicate: deduplicate);
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

MutablePaginatedComputedState<T, C> _usePaginatedComputedState<T, C>(
  Future<PaginatedPage<T, C>> Function(C? cursor) compute, {
  bool Function(T a, T b)? deduplicate,
}) {
  final itemsState = useState<List<T>>(const [], listen: false);
  final nextCursorState = useState<C?>(null, listen: false);
  final hasMoreState = useState<bool>(true, listen: false);
  final valueState = useState<ComputedStateValue<void>>(ComputedStateValue.notInitialized);
  final computeWrapper = useValueWrapper(compute);
  final deduplicateWrapper = useValueWrapper(deduplicate);
  final isMounted = useIsMounted();

  Future<void> loadMore() {
    if (!hasMoreState.value) return Future.value();

    final inProgress = valueState.value.maybeWhen(
      inProgress: (operation) => operation,
      orElse: () => null,
    );
    if (inProgress != null) return inProgress.value;

    final cursor = nextCursorState.value;
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
          nextCursorState.value = page.nextCursor;
          hasMoreState.value = page.nextCursor != null;
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
    nextCursorState.value = null;
    hasMoreState.value = true;
    valueState.value = ComputedStateValue.notInitialized;
  }

  Future<void> refresh() {
    clear();
    return loadMore();
  }

  return useMemoized(
    () => MutablePaginatedComputedState<T, C>(
      getItems: () => itemsState.value,
      getValue: () => valueState.value,
      getHasMore: () => hasMoreState.value,
      getNextCursor: () => nextCursorState.value,
      loadMore: loadMore,
      refresh: refresh,
      clear: clear,
    ),
  );
}
