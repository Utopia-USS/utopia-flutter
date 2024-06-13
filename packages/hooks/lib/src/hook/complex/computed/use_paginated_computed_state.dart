import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state_value.dart';
import 'package:utopia_hooks/src/hook/complex/computed/use_computed_state.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

///JK workaround: reconsider implementation of [ComputedState] to avoid unnecessary wrappers
class PaginationComputedState<T> {
  ///Set of computed items
  final List<T> values;

  /// [ComputedState] responsible for handling updates
  final MutableComputedState<void> computedState;

  /// Indicates that the result of the last compute didn't reach desired limit,
  /// meaning there are no more items to compute
  final bool reachedMax;

  /// Custom refresh function
  ///
  /// Since we are caching results of the [computedState], [computedState.refresh] is insufficient
  final Future<void> Function() refresh;

  PaginationComputedState({
    required this.computedState,
    required this.values,
    required this.refresh,
    required this.reachedMax,
  });
}

PaginationComputedState<T> usePaginatedComputedState<T>(
  Future<Iterable<T>> Function(int offset, int limit) compute, {
  int limit = 12,
  bool shouldCompute = true,

  /// Comparator for duplicates removal after [compute]
  bool Function(T a, T b)? comparator,
}) {
  return useDebugGroup(
    debugLabel: 'usePagingState<$T>()',
    debugFillProperties: (properties) =>
        properties..add(DiagnosticsProperty("shouldCompute", shouldCompute, defaultValue: true)),
    () {
      final pagingEnabled = useState(false);
      final offsetState = useState<int>(0);
      final itemsState = useState<Iterable<T>>([]);

      final computedState = useAutoComputedState(
        () async {
          if (pagingEnabled.value) {
            final result = await compute(offsetState.value, limit);

            if (comparator != null) {
              final filtered = result.where(
                (a) => !itemsState.value.any((b) => comparator.call(a, b)),
              );
              itemsState.value = [...itemsState.value, ...filtered];

              /// adds length from [result] instead of [filtered] in order to avoid more duplicates
              offsetState.value += result.length;
            } else {
              itemsState.value = [...itemsState.value, ...result];
            }

            /// block further paging after reaching limit
            if (result.length < limit) pagingEnabled.value = false;
          }
        },
        shouldCompute: shouldCompute,
        keys: [shouldCompute],
      );

      Future<void> refresh() async {
        itemsState.value = [];
        offsetState.value = 0;
        pagingEnabled.value = true;
        await computedState.refresh();
      }

      return PaginationComputedState(
        computedState: computedState,
        values: itemsState.value.toList(),
        refresh: refresh,
        reachedMax: pagingEnabled.value,
      );
    },
  );
}
