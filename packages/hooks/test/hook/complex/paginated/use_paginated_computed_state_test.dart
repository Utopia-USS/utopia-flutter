import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

typedef _State = MutablePaginatedComputedState<int, int>;

PaginatedPage<int, int> _page(int cursor, {int pageSize = 3, int? totalPages = 3}) {
  final items = List.generate(pageSize, (i) => cursor * pageSize + i);
  final isLast = totalPages != null && cursor >= totalPages - 1;
  return PaginatedPage(items: items, nextCursor: isLast ? null : cursor + 1);
}

void main() {
  group("usePaginatedComputedState", () {
    late SimpleHookContext<_State> context;

    tearDown(() {
      if (context.mounted) context.dispose();
    });

    group("initial load", () {
      test("items are null before first load completes", () async {
        final completer = Completer<PaginatedPage<int, int>>();
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>((_) => completer.future, initialCursor: 0),
        );

        expect(context.value.items, null);
        expect(context.value.isLoading, true);
        expect(context.value.isInitialized, false);
        expect(context.value.hasError, false);
        expect(context.value.hasMore, true);
      });

      test("first page loads automatically", () async {
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>((c) async => _page(c), initialCursor: 0),
        );

        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);
        expect(context.value.cursor, 1);
        expect(context.value.hasMore, true);
        expect(context.value.isLoading, false);
        expect(context.value.isInitialized, true);
      });

      test("initialCursor is passed to compute on first load", () async {
        final cursors = <int>[];
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async {
              cursors.add(c);
              return _page(c);
            },
            initialCursor: 42,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        expect(cursors.first, 42);
      });
    });

    group("loadMore", () {
      test("appends next page items and advances cursor", () async {
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>((c) async => _page(c), initialCursor: 0),
        );

        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);
        expect(context.value.cursor, 1);

        await context.value.loadMore();
        expect(context.value.items, [0, 1, 2, 3, 4, 5]);
        expect(context.value.cursor, 2);
        expect(context.value.hasMore, true);
      });

      test("hasMore becomes false when nextCursor is null", () async {
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async => _page(c, totalPages: 2),
            initialCursor: 0,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        await context.value.loadMore();

        expect(context.value.items, [0, 1, 2, 3, 4, 5]);
        expect(context.value.hasMore, false);
      });

      test("is a no-op when hasMore is false", () async {
        var callCount = 0;
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async {
              callCount++;
              return _page(c, totalPages: 1);
            },
            initialCursor: 0,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        expect(context.value.hasMore, false);
        expect(callCount, 1);

        await context.value.loadMore();
        expect(callCount, 1);
        expect(context.value.items, [0, 1, 2]);
      });

      test("concurrent calls share the in-flight operation", () async {
        var callCount = 0;
        final completers = <Completer<PaginatedPage<int, int>>>[];
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) {
              callCount++;
              final completer = Completer<PaginatedPage<int, int>>();
              completers.add(completer);
              return completer.future;
            },
            initialCursor: 0,
          ),
        );

        // Resolve the auto-triggered first-page load.
        completers.first.complete(_page(0));
        await context.waitUntil((s) => s.items != null);
        expect(callCount, 1);

        final first = context.value.loadMore();
        final second = context.value.loadMore();
        expect(callCount, 2);

        completers.last.complete(_page(1));
        await Future.wait([first, second]);
        expect(callCount, 2);
        expect(context.value.items, [0, 1, 2, 3, 4, 5]);
      });

      test("does not update state after context is disposed", () async {
        final completer = Completer<PaginatedPage<int, int>>();
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>((_) => completer.future, initialCursor: 0),
        );

        expect(context.value.isLoading, true);
        final state = context.value;

        context.dispose();
        completer.complete(_page(0));
        await Future<void>.delayed(Duration.zero);

        expect(state.items, null);
        expect(state.isLoading, true);
      });
    });

    group("error handling", () {
      // NOTE: Auto-triggered error (via `useEffect(() => unawaited(state.refresh()))`) is hard to
      // test directly — the uncaught async error from the fire-and-forget refresh propagates
      // through the Dart zone and fails the test before assertions run. Tests below use manual
      // `refresh()` so the returned Future can be awaited / error-handled. This still exercises
      // the same `load()` function that auto-triggering uses (verified by "first page loads
      // automatically").
      test("stores error on failed load", () async {
        final completer = Completer<PaginatedPage<int, int>>();
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (_) => completer.future,
            initialCursor: 0,
            shouldCompute: false,
          ),
        );

        final refreshFuture = context.value.refresh();
        expect(context.value.isLoading, true);

        completer.completeError("boom");
        await expectLater(refreshFuture, throwsA("boom"));

        expect(context.value.error, "boom");
        expect(context.value.items, null);
        expect(context.value.isLoading, false);
      });

      test("error is cleared when next load starts", () async {
        final completers = <Completer<PaginatedPage<int, int>>>[];
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) {
              final completer = Completer<PaginatedPage<int, int>>();
              completers.add(completer);
              return completer.future;
            },
            initialCursor: 0,
            shouldCompute: false,
          ),
        );

        final firstRefresh = context.value.refresh();
        completers.first.completeError("boom");
        await expectLater(firstRefresh, throwsA("boom"));
        expect(context.value.error, "boom");

        final secondRefresh = context.value.refresh();
        expect(context.value.error, null);
        expect(context.value.isLoading, true);

        completers.last.complete(_page(0));
        await secondRefresh;
        expect(context.value.hasError, false);
        expect(context.value.items, [0, 1, 2]);
      });

      test("keeps previously loaded items when loadMore fails", () async {
        var callCount = 0;
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async {
              callCount++;
              if (callCount == 2) throw "boom";
              return _page(c);
            },
            initialCursor: 0,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);

        await context.value.loadMore().catchError((_) {});
        expect(context.value.items, [0, 1, 2]);
        expect(context.value.error, "boom");
      });
    });

    group("refresh", () {
      test("default keeps items visible during reload", () async {
        final completers = <Completer<PaginatedPage<int, int>>>[];
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) {
              final completer = Completer<PaginatedPage<int, int>>();
              completers.add(completer);
              return completer.future;
            },
            initialCursor: 0,
          ),
        );

        completers.first.complete(_page(0));
        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);

        unawaited(context.value.refresh());
        expect(context.value.items, [0, 1, 2]);
        expect(context.value.isLoading, true);
        expect(context.value.cursor, 0);

        completers.last.complete(_page(0, pageSize: 2));
        await context.waitUntil((s) => !s.isLoading);
        expect(context.value.items, [0, 1]);
      });

      test("clearCache: true drops items to null immediately", () async {
        final completers = <Completer<PaginatedPage<int, int>>>[];
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) {
              final completer = Completer<PaginatedPage<int, int>>();
              completers.add(completer);
              return completer.future;
            },
            initialCursor: 0,
          ),
        );

        completers.first.complete(_page(0));
        await context.waitUntil((s) => s.items != null);

        unawaited(context.value.refresh(clearCache: true));
        expect(context.value.items, null);
        expect(context.value.isLoading, true);

        completers.last.complete(_page(0));
        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);
      });

      test("cancels in-flight loadMore", () async {
        final completers = <Completer<PaginatedPage<int, int>>>[];
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) {
              final completer = Completer<PaginatedPage<int, int>>();
              completers.add(completer);
              return completer.future;
            },
            initialCursor: 0,
          ),
        );

        completers[0].complete(_page(0));
        await context.waitUntil((s) => s.items != null);
        expect(context.value.cursor, 1);

        unawaited(context.value.loadMore());
        expect(context.value.cursor, 1);
        expect(context.value.isLoading, true);

        unawaited(context.value.refresh());
        expect(context.value.cursor, 0);
        expect(context.value.items, [0, 1, 2]);
        expect(context.value.isLoading, true);

        completers.last.complete(_page(0, pageSize: 2));
        await context.waitUntil((s) => s.items?.length == 2);

        // The cancelled loadMore's completer can be resolved, but must not leak into state.
        completers[1].complete(_page(1));
        await Future<void>.delayed(Duration.zero);
        expect(context.value.items, [0, 1]);
      });

      test("resets cursor and hasMore", () async {
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async => _page(c, totalPages: 2),
            initialCursor: 0,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        await context.value.loadMore();
        expect(context.value.hasMore, false);
        expect(context.value.cursor, 1);

        await context.value.refresh();
        expect(context.value.hasMore, true);
        expect(context.value.cursor, 1);
        expect(context.value.items, [0, 1, 2]);
      });
    });

    group("clear", () {
      test("resets all fields without triggering reload", () async {
        var callCount = 0;
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async {
              callCount++;
              return _page(c);
            },
            initialCursor: 0,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        expect(callCount, 1);

        context.value.clear();
        expect(context.value.items, null);
        expect(context.value.cursor, 0);
        expect(context.value.hasMore, true);
        expect(context.value.error, null);
        expect(context.value.isLoading, false);

        await Future<void>.delayed(Duration.zero);
        expect(callCount, 1);
      });

      test("cancels in-flight load", () async {
        final completer = Completer<PaginatedPage<int, int>>();
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>((_) => completer.future, initialCursor: 0),
        );

        expect(context.value.isLoading, true);
        context.value.clear();
        expect(context.value.isLoading, false);

        completer.complete(_page(0));
        await Future<void>.delayed(Duration.zero);
        expect(context.value.items, null);
      });
    });

    group("shouldCompute", () {
      test("false initially — no load", () async {
        var callCount = 0;
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async {
              callCount++;
              return _page(c);
            },
            initialCursor: 0,
            shouldCompute: false,
          ),
        );

        await Future<void>.delayed(Duration.zero);
        expect(callCount, 0);
        expect(context.value.items, null);
        expect(context.value.isLoading, false);
      });

      test("transition false → true triggers load", () async {
        final shouldCompute = ValueNotifier(false);
        addTearDown(shouldCompute.dispose);

        context = SimpleHookContext(
          () {
            useListenable(shouldCompute);
            return usePaginatedComputedState<int, int>(
              (c) async => _page(c),
              initialCursor: 0,
              shouldCompute: shouldCompute.value,
            );
          },
        );

        expect(context.value.items, null);

        shouldCompute.value = true;
        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);
      });

      test("clearOnShouldComputeFalse: true clears state", () async {
        final shouldCompute = ValueNotifier(true);
        addTearDown(shouldCompute.dispose);

        context = SimpleHookContext(
          () {
            useListenable(shouldCompute);
            return usePaginatedComputedState<int, int>(
              (c) async => _page(c),
              initialCursor: 0,
              shouldCompute: shouldCompute.value,
              clearOnShouldComputeFalse: true,
            );
          },
        );

        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);

        shouldCompute.value = false;
        expect(context.value.items, null);
      });
    });

    group("keys", () {
      test("change triggers refresh from initialCursor", () async {
        final key = ValueNotifier(0);
        addTearDown(key.dispose);
        final cursors = <int>[];

        context = SimpleHookContext(
          () {
            useListenable(key);
            return usePaginatedComputedState<int, int>(
              (c) async {
                cursors.add(c);
                return _page(c);
              },
              initialCursor: 0,
              keys: [key.value],
            );
          },
        );

        await context.waitUntil((s) => s.items != null);
        await context.value.loadMore();
        expect(context.value.cursor, 2);

        key.value = 1;
        await context.waitUntil((s) => s.cursor == 1 && !s.isLoading);
        expect(cursors, [0, 1, 0]);
        expect(context.value.items, [0, 1, 2]);
      });

      test("items stay visible across keys change (no flicker)", () async {
        final key = ValueNotifier(0);
        addTearDown(key.dispose);
        final completers = <Completer<PaginatedPage<int, int>>>[];

        context = SimpleHookContext(
          () {
            useListenable(key);
            return usePaginatedComputedState<int, int>(
              (c) {
                final completer = Completer<PaginatedPage<int, int>>();
                completers.add(completer);
                return completer.future;
              },
              initialCursor: 0,
              keys: [key.value],
            );
          },
        );

        completers.first.complete(_page(0));
        await context.waitUntil((s) => s.items != null);
        expect(context.value.items, [0, 1, 2]);

        key.value = 1;
        expect(context.value.items, [0, 1, 2]);
        expect(context.value.isLoading, true);

        completers.last.complete(_page(0, pageSize: 2));
        await context.waitUntil((s) => s.items?.length == 2);
        expect(context.value.items, [0, 1]);
      });
    });

    group("debounceDuration", () {
      test("delays first-page load", () async {
        var callCount = 0;
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async {
              callCount++;
              return _page(c);
            },
            initialCursor: 0,
            debounceDuration: const Duration(milliseconds: 100),
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(callCount, 0);
        expect(context.value.items, null);

        await context.waitUntil((s) => s.items != null);
        expect(callCount, 1);
      });

      test("does not delay subsequent loadMore calls", () async {
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async => _page(c),
            initialCursor: 0,
            debounceDuration: const Duration(milliseconds: 50),
          ),
        );

        await context.waitUntil((s) => s.items != null);
        final stopwatch = Stopwatch()..start();
        await context.value.loadMore();
        stopwatch.stop();

        expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 50)));
        expect(context.value.items, [0, 1, 2, 3, 4, 5]);
      });
    });

    group("deduplicateBy", () {
      test("drops items whose identifier matches already-collected items", () async {
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async => PaginatedPage(
              items: c == 0 ? [0, 1, 2] : [2, 3, 4],
              nextCursor: c == 0 ? 1 : null,
            ),
            initialCursor: 0,
            deduplicateBy: (item) => item,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        await context.value.loadMore();

        expect(context.value.items, [0, 1, 2, 3, 4]);
      });

      test("without deduplicateBy, duplicates are kept", () async {
        context = SimpleHookContext(
          () => usePaginatedComputedState<int, int>(
            (c) async => PaginatedPage(
              items: c == 0 ? [0, 1, 2] : [2, 3, 4],
              nextCursor: c == 0 ? 1 : null,
            ),
            initialCursor: 0,
          ),
        );

        await context.waitUntil((s) => s.items != null);
        await context.value.loadMore();

        expect(context.value.items, [0, 1, 2, 2, 3, 4]);
      });
    });
  });
}
