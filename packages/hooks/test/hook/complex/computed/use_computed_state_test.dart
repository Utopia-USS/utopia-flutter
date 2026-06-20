import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

typedef _State = MutableComputedState<int>;

bool _isReady(_State s) => s.value is ComputedStateValueReady;

bool _hasError(_State s) => s.value is ComputedStateValueFailed;

Object? _errorOf(_State s) => s.value.maybeWhen(failed: (e) => e, orElse: () => null);

/// Awaits [future], returning the error it throws (or `null` if it completes).
Future<Object?> _captureError(Future<void> future) =>
    future.then<Object?>((_) => null).catchError((Object e) => e);

void main() {
  group("useComputedState", () {
    late SimpleHookContext<_State> context;

    tearDown(() {
      try {
        if (context.mounted) context.dispose();
      } on Error {
        // late var not initialized — nothing to dispose.
      }
    });

    group("base", () {
      test("is not initialized and does not compute before refresh", () async {
        var callCount = 0;
        context = SimpleHookContext(
          () => useComputedState<int>(() async {
            callCount++;
            return 42;
          }),
        );

        await Future<void>.delayed(Duration.zero);
        expect(callCount, 0);
        expect(context.value.isInitialized, false);
        expect(context.value.valueOrNull, null);
        expect(context.value.value, isA<ComputedStateValueNotInitialized>());
      });

      test("refresh computes and stores the value", () async {
        final completer = Completer<int>();
        context = SimpleHookContext(() => useComputedState<int>(() => completer.future));

        final refreshFuture = context.value.refresh();
        expect(context.value.value, isA<ComputedStateValueInProgress<int>>());

        completer.complete(42);
        expect(await refreshFuture, 42);
        expect(context.value.valueOrNull, 42);
        expect(context.value.isInitialized, true);
      });

      test("refreshOrWait shares the in-flight operation", () async {
        var callCount = 0;
        final completer = Completer<int>();
        context = SimpleHookContext(
          () => useComputedState<int>(() {
            callCount++;
            return completer.future;
          }),
        );

        final first = context.value.refresh();
        final second = context.value.refresh();
        expect(callCount, 1);

        completer.complete(42);
        expect(await Future.wait([first, second]), [42, 42]);
        expect(callCount, 1);
      });

      test("stores error on failed compute", () async {
        final completer = Completer<int>();
        context = SimpleHookContext(() => useComputedState<int>(() => completer.future));

        final refreshFuture = context.value.refresh();
        final error = Exception("boom");
        completer.completeError(error);

        expect(await _captureError(refreshFuture), error);
        expect(_hasError(context.value), true);
        expect(_errorOf(context.value), error);
        expect(context.value.valueOrNull, null);
      });

      test("clear resets to notInitialized and cancels in-flight compute", () async {
        final completer = Completer<int>();
        context = SimpleHookContext(() => useComputedState<int>(() => completer.future));

        unawaited(context.value.refresh());
        expect(context.value.value, isA<ComputedStateValueInProgress<int>>());

        context.value.clear();
        expect(context.value.value, isA<ComputedStateValueNotInitialized>());

        // Resolving the cancelled operation must not leak into state.
        completer.complete(42);
        await Future<void>.delayed(Duration.zero);
        expect(context.value.valueOrNull, null);
      });

      test("updateValue sets ready value explicitly", () async {
        context = SimpleHookContext(() => useComputedState<int>(() async => 1));

        context.value.updateValue(99);
        expect(context.value.valueOrNull, 99);
        expect(_isReady(context.value), true);
      });

      test("updateValue during in-flight refresh keeps the manual value", () async {
        final completer = Completer<int>();
        context = SimpleHookContext(() => useComputedState<int>(() => completer.future));

        unawaited(context.value.refresh());
        expect(context.value.value, isA<ComputedStateValueInProgress<int>>());

        // Manually override while the compute is still running.
        context.value.updateValue(99);
        expect(context.value.valueOrNull, 99);
        expect(_isReady(context.value), true);

        // Resolving the now-cancelled compute must not clobber the manual value.
        completer.complete(42);
        await Future<void>.delayed(Duration.zero);
        expect(context.value.valueOrNull, 99);
        expect(_isReady(context.value), true);
      });

      test("does not update state after context is disposed", () async {
        final completer = Completer<int>();
        context = SimpleHookContext(() => useComputedState<int>(() => completer.future));

        final state = context.value;
        unawaited(state.refresh());
        context.dispose();

        completer.complete(42);
        await Future<void>.delayed(Duration.zero);
        expect(state.valueOrNull, null);
      });
    });

    group("retryable", () {
      test("error is not retryable by default", () async {
        final completer = Completer<int>();
        context = SimpleHookContext(() => useComputedState<int>(() => completer.future));

        final refreshFuture = context.value.refresh();
        final error = Exception("boom");
        completer.completeError(error);

        final captured = await _captureError(refreshFuture);
        expect(captured, error);
        expect(Retryable.tryGet(captured!), null);
      });

      test("isRetryable: true attaches a Retryable to the error", () async {
        final completer = Completer<int>();
        context = SimpleHookContext(
          () => useComputedState<int>(() => completer.future, isRetryable: true),
        );

        final refreshFuture = context.value.refresh();
        final error = Exception("boom");
        completer.completeError(error);

        final captured = await _captureError(refreshFuture);
        expect(captured, error);
        expect(Retryable.tryGet(captured!), isNotNull);
      });

      test("retry re-runs compute and a subsequent success populates state", () async {
        var callCount = 0;
        final completers = <Completer<int>>[];
        context = SimpleHookContext(
          () => useComputedState<int>(
            () {
              callCount++;
              final completer = Completer<int>();
              completers.add(completer);
              return completer.future;
            },
            isRetryable: true,
          ),
        );

        // First attempt fails.
        final firstRefresh = context.value.refresh();
        completers.first.completeError(Exception("boom"));
        final captured = await _captureError(firstRefresh);
        expect(callCount, 1);
        expect(_hasError(context.value), true);

        // Retry via the Retryable attached to the error.
        Retryable.tryGet(captured!)!.retry();
        expect(callCount, 2);
        expect(context.value.value, isA<ComputedStateValueInProgress<int>>());

        // Second attempt succeeds.
        completers.last.complete(42);
        await context.waitUntil(_isReady);
        expect(context.value.valueOrNull, 42);
        expect(_hasError(context.value), false);
      });

      test("every failure is independently retryable", () async {
        final completers = <Completer<int>>[];
        context = SimpleHookContext(
          () => useComputedState<int>(
            () {
              final completer = Completer<int>();
              completers.add(completer);
              return completer.future;
            },
            isRetryable: true,
          ),
        );

        // First failure is retryable.
        final firstRefresh = context.value.refresh();
        final firstError = Exception("boom-1");
        completers[0].completeError(firstError);
        expect(await _captureError(firstRefresh), firstError);
        expect(Retryable.tryGet(firstError), isNotNull);

        // A subsequent failure is also retryable.
        final secondRefresh = context.value.refresh();
        final secondError = Exception("boom-2");
        completers[1].completeError(secondError);
        expect(await _captureError(secondRefresh), secondError);
        expect(Retryable.tryGet(secondError), isNotNull);
      });
    });

    group("useAutoComputedState retryable", () {
      // NOTE: auto-triggered (fire-and-forget) failures propagate uncaught through the Dart zone
      // and fail the test before assertions run. We use shouldCompute: false + manual `refresh()`
      // so the returned Future can be error-handled. This still exercises useAutoComputedState's
      // isRetryable wiring.
      test("threads isRetryable through to compute failures", () async {
        var callCount = 0;
        final completers = <Completer<int>>[];
        final context = SimpleHookContext<_State>(
          () => useAutoComputedState<int>(
            () {
              callCount++;
              final completer = Completer<int>();
              completers.add(completer);
              return completer.future;
            },
            shouldCompute: false,
            isRetryable: true,
          ),
        );
        addTearDown(context.dispose);

        final refreshFuture = context.value.refresh();
        final error = Exception("boom");
        completers.first.completeError(error);

        final captured = await _captureError(refreshFuture);
        expect(captured, error);
        expect(callCount, 1);

        final retryable = Retryable.tryGet(error);
        expect(retryable, isNotNull);

        retryable!.retry();
        expect(callCount, 2);
        completers.last.complete(7);
        await context.waitUntil(_isReady);
        expect(context.value.valueOrNull, 7);
      });
    });
  });
}
