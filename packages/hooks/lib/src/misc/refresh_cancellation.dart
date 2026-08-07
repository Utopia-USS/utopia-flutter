import 'dart:async';

import 'package:async/async.dart';

/// Thrown by computed- and paginated-state `refresh()` / `loadMore()` when the awaited
/// operation is cancelled before it completes.
///
/// These methods previously returned [CancelableOperation.value], which - per
/// `package:async` - never completes (neither with a value nor an error) once the operation
/// is cancelled. Anyone awaiting `refresh()` / `loadMore()` while the underlying load was
/// cancelled (by `clear()`, a `keys` change, `shouldCompute` going false, or another
/// `refresh()`) would hang forever. They now throw this exception instead, so awaiters can
/// react (or ignore it via [RefreshCancellationFutureExtension]).
class ComputedStateRefreshCancelled implements Exception {
  const ComputedStateRefreshCancelled();

  @override
  String toString() => 'ComputedStateRefreshCancelled: refresh was cancelled before completing';
}

extension RefreshCancellationOperationExtension<T> on CancelableOperation<T> {
  /// Awaits this operation, forwarding its value or error, but throwing
  /// [ComputedStateRefreshCancelled] if it is cancelled - instead of hanging forever, which
  /// is what awaiting [CancelableOperation.value] does on cancellation.
  Future<T> valueOrThrowIfCancelled() async {
    // valueOrCancellation() settles on value, error, AND cancel (unlike `value`).
    await valueOrCancellation();
    if (isCanceled) throw const ComputedStateRefreshCancelled();
    return value; // already complete here (value or error forwarded by the await above)
  }
}

extension RefreshCancellationFutureExtension<T> on Future<T> {
  /// Returns a future that completes normally when this throws
  /// [ComputedStateRefreshCancelled], and otherwise forwards this future's value or error.
  ///
  /// Use for awaitable callers that must not surface a benign cancellation - e.g.
  /// `RefreshIndicator.onRefresh`, which would otherwise error (or, pre-fix, hang).
  Future<void> swallowingRefreshCancellation() => then<void>((_) {}).onError<ComputedStateRefreshCancelled>((_, __) {});

  /// Fire-and-forget variant of [swallowingRefreshCancellation]: swallows
  /// [ComputedStateRefreshCancelled] but lets any other error surface as an unhandled zone
  /// error, preserving the let-it-crash behavior of auto-triggered loads. Use for internal
  /// callers that read the result via state rather than the returned future.
  void ignoreRefreshCancellation() {
    unawaited(swallowingRefreshCancellation());
  }
}
