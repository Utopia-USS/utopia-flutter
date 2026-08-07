import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

import 'package:utopia_hooks_query/src/core/core.dart';
import 'package:utopia_hooks_query/src/hooks/hooks.dart';
import '../../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QueryClient client;

  setUp(() {
    client = QueryClient(
      defaultQueryOptions: DefaultQueryOptions(
        gcDuration: GcDuration.infinity,
        retry: (_, __) => null,
      ),
    );
  });

  tearDown(() {
    client.clear();
  });

  test('SHOULD succeed fetching on mount', () async {
    final completer = Completer<void>();
    final context = SimpleHookContext(
      () => useInfiniteQuery<String, Object, int>(
        const ['test'],
        (context) async {
          await completer.future;
          return 'page-${context.pageParam}';
        },
        initialPageParam: 0,
        nextPageParamBuilder: (data) => data.pageParams.last + 1,
        client: client,
      ),
    );

    expect(context.value.status, QueryStatus.pending);
    expect(context.value.fetchStatus, FetchStatus.fetching);
    expect(context.value.data, isNull);
    expect(context.value.dataUpdatedAt, isNull);
    expect(context.value.dataUpdateCount, 0);

    final updatedAt = clock.now();
    completer.complete();
    await asyncYield();

    expect(context.value.status, QueryStatus.success);
    expect(context.value.fetchStatus, FetchStatus.idle);
    expect(context.value.data, InfiniteData(['page-0'], [0]));
    expect(context.value.dataUpdatedAt, after(updatedAt));
    expect(context.value.dataUpdateCount, 1);
    context.dispose();
  });

  test('SHOULD fail fetching on mount', () async {
    final expectedError = Exception();
    final completer = Completer<void>();

    final context = SimpleHookContext(
      () => useInfiniteQuery<String, Object, int>(
        const ['test'],
        (context) async {
          await completer.future;
          throw expectedError;
        },
        initialPageParam: 0,
        nextPageParamBuilder: (data) => data.pageParams.last + 1,
        client: client,
      ),
    );

    expect(context.value.status, QueryStatus.pending);
    expect(context.value.fetchStatus, FetchStatus.fetching);
    expect(context.value.error, isNull);
    expect(context.value.errorUpdatedAt, isNull);
    expect(context.value.errorUpdateCount, 0);

    final erroredAt = clock.now();
    completer.complete();
    await asyncYield();

    expect(context.value.status, QueryStatus.error);
    expect(context.value.fetchStatus, FetchStatus.idle);
    expect(context.value.error, same(expectedError));
    expect(context.value.errorUpdatedAt, after(erroredAt));
    expect(context.value.errorUpdateCount, 1);
    context.dispose();
  });

  test('SHOULD fetch only once WHEN multiple hooks share same key', () async {
    var fetches = 0;
    final completer = Completer<void>();

    final context1 = SimpleHookContext(
      () => useInfiniteQuery<String, Object, int>(
        const ['key'],
        (context) async {
          await completer.future;
          fetches++;
          return 'page-$fetches';
        },
        initialPageParam: 0,
        nextPageParamBuilder: (data) => data.pageParams.last + 1,
        client: client,
      ),
    );
    final context2 = SimpleHookContext(
      () => useInfiniteQuery<String, Object, int>(
        const ['key'],
        (context) async {
          await completer.future;
          fetches++;
          return 'page-$fetches';
        },
        initialPageParam: 0,
        nextPageParamBuilder: (data) => data.pageParams.last + 1,
        client: client,
      ),
    );

    expect(context1.value.data, null);
    expect(context2.value.data, null);

    completer.complete();
    await asyncYield();

    expect(fetches, 1);
    expect(context1.value.pages, ['page-1']);
    expect(context2.value.pages, ['page-1']);
    context1.dispose();
    context2.dispose();
  });

  test('SHOULD fetch individually WHEN multiple hooks have different keys', () async {
    final completer1 = Completer<void>();
    final completer2 = Completer<void>();

    final context1 = SimpleHookContext(
      () => useInfiniteQuery<String, Object, int>(
        const ['key1'],
        (context) async {
          await completer1.future;
          return 'key1-page-${context.pageParam}';
        },
        initialPageParam: 0,
        nextPageParamBuilder: (_) => null,
        client: client,
      ),
    );
    final context2 = SimpleHookContext(
      () => useInfiniteQuery<String, Object, int>(
        const ['key2'],
        (context) async {
          await completer2.future;
          return 'key2-page-${context.pageParam}';
        },
        initialPageParam: 0,
        nextPageParamBuilder: (_) => null,
        client: client,
      ),
    );

    completer1.complete();
    await asyncYield();

    expect(context1.value.pages, ['key1-page-0']);
    expect(context2.value.pages, []);

    completer2.complete();
    await asyncYield();

    expect(context1.value.pages, ['key1-page-0']);
    expect(context2.value.pages, ['key2-page-0']);
    context1.dispose();
    context2.dispose();
  });

  group('Params: queryKey', () {
    test('SHOULD switch to new query WHEN queryKey changes', () async {
      var key = const <Object?>['test1'];
      final completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          key,
          (ctx) async {
            await completer.future;
            return '$key-page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completer.complete();
      await asyncYield();

      expect(context.value.status, QueryStatus.success);
      expect(context.value.pages, ['[test1]-page-0']);

      key = const ['test2'];
      context.rebuild();

      expect(context.value.status, QueryStatus.pending);
      expect(context.value.pages, []);

      await asyncYield();

      expect(context.value.status, QueryStatus.success);
      expect(context.value.pages, ['[test2]-page-0']);
      context.dispose();
    });
  });

  group('Params: queryFn', () {
    test('SHOULD receive correct InfiniteQueryFunctionContext', () async {
      late InfiniteQueryFunctionContext<int> capturedContext;

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['users', 123],
          (ctx) async {
            capturedContext = ctx;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 10,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          meta: {'key': 'value'},
          client: client,
        ),
      );

      await asyncYield();

      expect(capturedContext.queryKey, const ['users', 123]);
      expect(capturedContext.client, same(client));
      expect(capturedContext.signal, isA<AbortSignal>());
      expect(capturedContext.meta, {'key': 'value'});
      expect(capturedContext.pageParam, 10);
      expect(capturedContext.direction, FetchDirection.forward);
      context.dispose();
    });

    test('SHOULD receive context with direction forward WHEN fetchNextPage is called', () async {
      final capturedContexts = <InfiniteQueryFunctionContext<int>>[];
      var completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            capturedContexts.add(ctx);
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completer.complete();
      await asyncYield();

      expect(capturedContexts.length, 1);
      expect(capturedContexts[0].pageParam, 0);
      expect(capturedContexts[0].direction, FetchDirection.forward);

      completer = Completer<void>();
      context.value.fetchNextPage();
      await asyncYield();

      completer.complete();
      await asyncYield();

      expect(capturedContexts.length, 2);
      expect(capturedContexts[1].pageParam, 1);
      expect(capturedContexts[1].direction, FetchDirection.forward);
      context.dispose();
    });

    test('SHOULD receive context with direction backward WHEN fetchPreviousPage is called', () async {
      final capturedContexts = <InfiniteQueryFunctionContext<int>>[];
      var completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            capturedContexts.add(ctx);
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completer.complete();
      await asyncYield();

      expect(capturedContexts.length, 1);
      expect(capturedContexts[0].pageParam, 5);
      expect(capturedContexts[0].direction, FetchDirection.forward);

      completer = Completer<void>();
      context.value.fetchPreviousPage();
      await asyncYield();

      completer.complete();
      await asyncYield();

      expect(capturedContexts.length, 2);
      expect(capturedContexts[1].pageParam, 4);
      expect(capturedContexts[1].direction, FetchDirection.backward);
      context.dispose();
    });
  });

  group('Params: enabled', () {
    test('SHOULD fetch on mount WHEN enabled == true', () async {
      var fetches = 0;
      final completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          enabled: true,
          client: client,
        ),
      );

      completer.complete();
      await asyncYield();

      expect(fetches, 1);
      context.dispose();
    });

    test('SHOULD NOT fetch on mount WHEN enabled == false', () async {
      var fetches = 0;

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          enabled: false,
          client: client,
        ),
      );

      await asyncYield();

      expect(fetches, 0);
      context.dispose();
    });

    test('SHOULD fetch WHEN enabled changes from false to true', () async {
      var fetches = 0;
      var enabled = false;
      final completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          enabled: enabled,
          client: client,
        ),
      );

      await asyncYield();
      expect(fetches, 0);

      enabled = true;
      context.rebuild();

      completer.complete();
      await asyncYield();

      expect(fetches, 1);
      context.dispose();
    });

    test('SHOULD allow fetching next page WHEN enabled == false', () async {
      var fetches = 0;
      var enabled = true;
      var completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          enabled: enabled,
          client: client,
        ),
      );

      completer.complete();
      await asyncYield();
      expect(fetches, 1);

      enabled = false;
      context.rebuild();

      completer = Completer<void>();
      context.value.fetchNextPage();
      await asyncYield();

      completer.complete();
      await asyncYield();

      expect(fetches, 2);
      context.dispose();
    });

    test('SHOULD allow fetching previous page WHEN enabled == false', () async {
      var fetches = 0;
      var enabled = true;
      var completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          enabled: enabled,
          client: client,
        ),
      );

      completer.complete();
      await asyncYield();
      expect(fetches, 1);

      enabled = false;
      context.rebuild();

      completer = Completer<void>();
      context.value.fetchPreviousPage();
      await asyncYield();

      completer.complete();
      await asyncYield();

      expect(fetches, 2);
      context.dispose();
    });

    test('SHOULD allow refetching WHEN enabled == false', () async {
      var fetches = 0;
      var enabled = true;
      var completer = Completer<void>();

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          enabled: enabled,
          client: client,
        ),
      );

      completer.complete();
      await asyncYield();
      expect(fetches, 1);

      enabled = false;
      context.rebuild();

      completer = Completer<void>();
      context.value.refetch();
      await asyncYield();

      completer.complete();
      await asyncYield();

      expect(fetches, 2);
      context.dispose();
    });
  });

  group('Params: staleDuration', () {
    test(
        'SHOULD be stale immediately '
        'WHEN staleDuration == StaleDuration.zero', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.zero,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.isStale, isTrue);
        context.dispose();
      });
    });

    test(
        'SHOULD be stale '
        'WHEN staleDuration has elapsed', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.isStale, isFalse);

        context.dispose();
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            client: client,
          ),
        );

        expect(context.value.isStale, isTrue);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT be stale forever'
        'WHEN staleDuration == StaleDuration.infinity', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.infinity,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.isStale, isFalse);

        async.elapse(const Duration(days: 365));
        async.flushMicrotasks();

        expect(context.value.isStale, isFalse);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT be stale forever'
        'WHEN staleDuration == StaleDuration.static', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.static,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.isStale, isFalse);

        async.elapse(const Duration(days: 365));
        async.flushMicrotasks();

        expect(context.value.isStale, isFalse);
        context.dispose();
      });
    });

    test(
        'SHOULD be stale on cache invalidation '
        'WHEN staleDuration == StaleDuration.infinity', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.infinity,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.isStale, isFalse);

        context.dispose();
        client.invalidateQueries(queryKey: const ['test']);
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.infinity,
            client: client,
          ),
        );

        expect(context.value.isStale, isTrue);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT be stale on cache invalidation '
        'WHEN staleDuration == StaleDuration.static', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.static,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.isStale, isFalse);

        context.dispose();
        client.invalidateQueries(queryKey: const ['test']);
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.static,
            client: client,
          ),
        );

        expect(context.value.isStale, isFalse);
        context.dispose();
      });
    });
  });

  group('Params: gcDuration', () {
    test(
        'SHOULD remove query from cache '
        'WHEN gcDuration has elapsed '
        'AND there are no observers', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: const GcDuration(minutes: 5),
            client: client,
          ),
        );

        // Garbage collection is scheduled after fetch completes
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNotNull);

        context.dispose();
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNull);
      });
    });

    test(
        'SHOULD NOT remove query from cache '
        'WHEN gcDuration has elapsed '
        'AND there are remaining observers', () {
      fakeAsync((async) {
        // Create two hooks sharing the same key
        final context1 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: const GcDuration(minutes: 5),
            client: client,
          ),
        );
        final context2 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: const GcDuration(minutes: 5),
            client: client,
          ),
        );

        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNotNull);

        // Remove only the first hook, keeping the second one
        context1.dispose();

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        // Query should still exist because second hook is still mounted
        expect(client.cache.get(const ['test']), isNotNull);
        context2.dispose();
      });
    });

    test(
        'SHOULD remove query from cache immediately '
        'WHEN gcDuration == GcDuration.zero '
        'AND there are no observers', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: GcDuration.zero,
            client: client,
          ),
        );

        // Wait for fetch to complete
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNotNull);

        context.dispose();
        // Query should be removed immediately (after zero-duration timer fires)
        async.elapse(Duration.zero);
        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNull);
      });
    });

    test(
        'SHOULD NOT remove query from cache '
        'WHEN gcDuration == GcDuration.infinity', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: GcDuration.infinity,
            client: client,
          ),
        );

        context.dispose();
        async.elapse(const Duration(days: 365));
        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNotNull);
      });
    });

    test(
        'SHOULD use longest gcDuration '
        'WHEN multiple observers have different values', () {
      fakeAsync((async) {
        // Create two hooks with different gcDurations
        final context1 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: const GcDuration(minutes: 5),
            client: client,
          ),
        );
        final context2 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        // Garbage collection is scheduled after fetch completes
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNotNull);

        // Unmount both hooks
        context1.dispose();
        context2.dispose();

        // Wait for shorter gcDuration (5 minutes)
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        // Query should still exist (longest gcDuration is 10 minutes)
        expect(client.cache.get(const ['test']), isNotNull);

        // Wait for remaining time until longest gcDuration
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        // Now query should be removed
        expect(client.cache.get(const ['test']), isNull);
      });
    });

    test(
        'SHOULD use remaining observer gcDuration '
        'WHEN observer with longer gcDuration is unmounted first', () {
      fakeAsync((async) {
        // Create two hooks: hook1 with longer gcDuration, hook2 with shorter
        final context1 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );
        final context2 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            gcDuration: const GcDuration(minutes: 3),
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(client.cache.get(const ['test']), isNotNull);

        // Unmount hook1 (longer gcDuration), keep hook2 (shorter gcDuration)
        context1.dispose();

        // Query should still exist (hook2 is still mounted)
        expect(client.cache.get(const ['test']), isNotNull);

        // Unmount hook2 as well
        context2.dispose();

        // Wait for hook2's gcDuration (3 minutes), not hook1's (10 minutes)
        async.elapse(const Duration(minutes: 3));
        async.flushMicrotasks();

        // Query should be removed after hook2's gcDuration
        expect(client.cache.get(const ['test']), isNull);
      });
    });
  });

  group('Params: placeholder', () {
    test(
        'SHOULD use placeholder'
        '', () async {
      final completer = Completer<void>();
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (context) async {
            await completer.future;
            return 'page-${context.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          placeholder: const InfiniteData(['page-ph'], [0]),
          client: client,
        ),
      );

      expect(context.value.pages, ['page-ph']);
      expect(context.value.isPlaceholderData, isTrue);
      expect(context.value.isSuccess, isTrue);
      context.dispose();
    });

    test(
        'SHOULD NOT persist placeholder to cache'
        '', () async {
      final completer = Completer<void>();
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (context) async {
            await completer.future;
            return 'page-${context.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          placeholder: const InfiniteData(['page-ph'], [0]),
          client: client,
        ),
      );

      expect(client.cache.get(const ['test'])!.state.data, isNull);
      context.dispose();
    });

    test(
        'SHOULD be replaced by fetched data'
        '', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            placeholder: const InfiniteData(['page-ph'], [0]),
            client: client,
          ),
        );

        expect(context.value.pages, ['page-ph']);
        expect(context.value.isPlaceholderData, isTrue);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.pages, ['page-0']);
        expect(context.value.isPlaceholderData, isFalse);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT use placeholder '
        'WHEN data already exists', () {
      fakeAsync((async) {
        // First hook fetches real data
        final context1 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context1.value.pages, ['page-0']);

        // Second hook should use cached real data, not placeholder
        final context2 = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${context.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            placeholder: const InfiniteData(['page-ph'], [0]),
            client: client,
          ),
        );

        expect(context2.value.pages, ['page-0']);
        expect(context2.value.isPlaceholderData, isFalse);
        context1.dispose();
        context2.dispose();
      });
    });
  });

  group('Params: refetchOnMount', () {
    test(
        'SHOULD refetch on mount '
        'WHEN refetchOnMount == RefetchOnMount.stale '
        'AND data is stale', () {
      fakeAsync((async) {
        var fetches = 0;

        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.stale,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        // Make data stale
        context.dispose();
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.stale,
            client: client,
          ),
        );

        expect(context.value.isStale, isTrue);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 2);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT refetch on mount '
        'WHEN refetchOnMount == RefetchOnMount.stale '
        'AND data is fresh', () {
      fakeAsync((async) {
        var fetches = 0;

        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.stale,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        // Unmount first observer
        context.dispose();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.stale,
            client: client,
          ),
        );

        expect(context.value.isStale, isFalse);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT refetch on mount '
        'WHEN refetchOnMount == RefetchOnMount.never '
        'AND data is stale', () {
      fakeAsync((async) {
        var fetches = 0;

        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.never,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        // Make data stale
        context.dispose();
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.never,
            client: client,
          ),
        );

        expect(context.value.isStale, isTrue);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD refetch on mount '
        'WHEN refetchOnMount == RefetchOnMount.always '
        'AND data is fresh', () {
      fakeAsync((async) {
        var fetches = 0;

        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.always,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        context.dispose();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnMount: RefetchOnMount.always,
            client: client,
          ),
        );

        expect(context.value.isStale, isFalse);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 2);
        context.dispose();
      });
    });
  });

  group('Params: refetchOnResume', () {
    test(
        'SHOULD refetch on resume '
        'WHEN refetchOnResume == RefetchOnResume.stale '
        'AND data is stale', () {
      fakeAsync((async) {
        // Reset lifecycle so the resume transition is observed
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

        var fetches = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnResume: RefetchOnResume.stale,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 2);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT refetch on resume '
        'WHEN refetchOnResume == RefetchOnResume.stale '
        'AND data is fresh', () {
      fakeAsync((async) {
        // Reset lifecycle so the resume transition is observed
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

        var fetches = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnResume: RefetchOnResume.stale,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT refetch on resume '
        'WHEN refetchOnResume == RefetchOnResume.never '
        'AND data is stale', () {
      fakeAsync((async) {
        // Reset lifecycle so the resume transition is observed
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

        var fetches = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnResume: RefetchOnResume.never,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD refetch on resume '
        'WHEN refetchOnResume == RefetchOnResume.always '
        'AND data is fresh', () {
      fakeAsync((async) {
        // Reset lifecycle so the resume transition is observed
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

        var fetches = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: const StaleDuration(minutes: 5),
            refetchOnResume: RefetchOnResume.always,
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);

        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 2);
        context.dispose();
      });
    });
  });

  group('Parameter: refetchOnReconnect', () {
    test(
        'SHOULD refetch stale data '
        'WHEN refetchOnReconnect == RefetchOnReconnect.stale', () {
      fakeAsync((async) {
        final connectivityController = StreamController<bool>();
        addTearDown(connectivityController.close);

        final reconnectClient = QueryClient(
          connectivityChanges: connectivityController.stream,
        );
        addTearDown(reconnectClient.clear);

        var fetches = 0;
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.zero,
            refetchOnReconnect: RefetchOnReconnect.stale,
            client: reconnectClient,
          ),
        );

        // Emit initial online state
        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data?.pages, ['page-0']);
        expect(context.value.isStale, isTrue);
        expect(fetches, 1);

        // Go offline then back online - should trigger reconnect
        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.fetching);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data?.pages, ['page-0']);
        expect(fetches, 2);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT refetch fresh data '
        'WHEN refetchOnReconnect == RefetchOnReconnect.stale', () {
      fakeAsync((async) {
        final connectivityController = StreamController<bool>();
        addTearDown(connectivityController.close);

        final reconnectClient = QueryClient(
          connectivityChanges: connectivityController.stream,
        );
        addTearDown(reconnectClient.clear);

        var fetches = 0;
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.infinity,
            refetchOnReconnect: RefetchOnReconnect.stale,
            client: reconnectClient,
          ),
        );

        // Emit initial online state and process stream event
        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data?.pages, ['page-0']);
        expect(context.value.isStale, isFalse);
        expect(fetches, 1);

        // Go offline and go back online - should not trigger reconnect
        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data?.pages, ['page-0']);
        expect(fetches, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT refetch stale data '
        'WHEN refetchOnReconnect == RefetchOnReconnect.never', () {
      fakeAsync((async) {
        final connectivityController = StreamController<bool>();
        addTearDown(connectivityController.close);

        final reconnectClient = QueryClient(
          connectivityChanges: connectivityController.stream,
        );
        addTearDown(reconnectClient.clear);

        var fetches = 0;
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.zero,
            refetchOnReconnect: RefetchOnReconnect.never,
            client: reconnectClient,
          ),
        );

        // Emit initial online state and process stream event
        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data?.pages, ['page-0']);
        expect(context.value.isStale, isTrue);
        expect(fetches, 1);

        // Go offline and go back online - should NOT trigger reconnect since never
        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data?.pages, ['page-0']);
        expect(fetches, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data?.pages, ['page-0']);
        expect(fetches, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD refetch fresh data '
        'WHEN refetchOnReconnect == RefetchOnReconnect.always', () {
      fakeAsync((async) {
        final connectivityController = StreamController<bool>();
        addTearDown(connectivityController.close);

        final reconnectClient = QueryClient(
          connectivityChanges: connectivityController.stream,
        );
        addTearDown(reconnectClient.clear);

        var fetches = 0;
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              fetches++;
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.infinity,
            refetchOnReconnect: RefetchOnReconnect.always,
            client: reconnectClient,
          ),
        );

        // Emit initial online state and process stream event
        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data?.pages, ['page-0']);
        expect(context.value.isStale, isFalse);
        expect(fetches, 1);

        // Go offline and go back online - should trigger reconnect even when fresh
        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.fetching);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data?.pages, ['page-0']);
        expect(fetches, 2);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT refetch '
        'WHEN refetchOnReconnect == RefetchOnReconnect.always '
        'AND staleDuration == StaleDuration.static', () {
      fakeAsync((async) {
        final connectivityController = StreamController<bool>();
        addTearDown(connectivityController.close);

        final reconnectClient = QueryClient(
          connectivityChanges: connectivityController.stream,
        );
        addTearDown(reconnectClient.clear);

        var fetches = 0;
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              fetches++;
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            staleDuration: StaleDuration.static,
            refetchOnReconnect: RefetchOnReconnect.always,
            client: reconnectClient,
          ),
        );

        // Emit initial online state and process stream event
        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data?.pages, ['page-0']);
        expect(context.value.isStale, isFalse);
        expect(fetches, 1);

        // Go offline and go back online - should NOT trigger reconnect since static
        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data?.pages, ['page-0']);
        expect(fetches, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data?.pages, ['page-0']);
        expect(fetches, 1);
        context.dispose();
      });
    });
  });

  group('Params: refetchInterval', () {
    test(
        'SHOULD refetch at interval'
        '', () {
      fakeAsync((async) {
        var fetches = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              fetches++;
              return 'page-$fetches';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            refetchInterval: const Duration(seconds: 5),
            client: client,
          ),
        );

        async.flushMicrotasks();
        expect(fetches, 1);

        // Wait for first interval
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        expect(fetches, 2);

        // Wait for second interval
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        expect(fetches, 3);
        context.dispose();
      });
    });

    test(
        'SHOULD stop refetch interval on unmount'
        '', () {
      fakeAsync((async) {
        var fetches = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              fetches++;
              return 'page-$fetches';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            refetchInterval: const Duration(seconds: 5),
            client: client,
          ),
        );

        async.flushMicrotasks();
        expect(fetches, 1);

        // Unmount
        context.dispose();

        // Interval should not fire after unmount
        async.elapse(const Duration(seconds: 100));
        async.flushMicrotasks();
        expect(fetches, 1);
      });
    });
  });

  group('Params: retry', () {
    test(
        'SHOULD retry on failure '
        'WHEN retry returns Duration', () {
      fakeAsync((async) {
        var attempts = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              attempts++;
              throw Exception();
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retry: (retryCount, error) {
              if (retryCount >= 3) return null;
              return const Duration(seconds: 1);
            },
            client: client,
          ),
        );

        // First attempt fails, retry is scheduled
        async.flushMicrotasks();
        expect(attempts, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(attempts, 2);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(attempts, 3);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(attempts, 4);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT retry '
        'WHEN retry returns null', () {
      fakeAsync((async) {
        var attempts = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              attempts++;
              throw Exception();
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retry: (_, __) => null,
            client: client,
          ),
        );

        // First attempt fails
        async.flushMicrotasks();
        expect(attempts, 1);
        expect(context.value.isError, isTrue);

        // Wait more - no retries should happen
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        expect(attempts, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT retry further '
        'WHEN retry returns null ongoing', () {
      fakeAsync((async) {
        var attempts = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (context) async {
              attempts++;
              throw Exception();
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retry: (retryCount, error) {
              if (retryCount >= 2) return null; // Max 2 retries
              return const Duration(seconds: 1);
            },
            client: client,
          ),
        );

        // First attempt fails
        async.flushMicrotasks();
        expect(attempts, 1);

        // First retry
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(attempts, 2);

        // Second retry
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(attempts, 3);

        // No more retries - wait and verify
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        expect(attempts, 3);
        expect(context.value.isError, isTrue);
        context.dispose();
      });
    });
  });

  group('Params: retryOnMount', () {
    test(
        'SHOULD retry on mount '
        'WHEN retryOnMount == true '
        'AND query is in error state', () {
      fakeAsync((async) {
        var fetches = 0;

        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              throw Exception();
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retry: (_, __) => null,
            retryOnMount: true,
            client: client,
          ),
        );

        // Wait for first fetch to fail
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.isError, isTrue);
        expect(fetches, 1);

        // Unmount and remount
        context.dispose();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              throw Exception();
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retry: (_, __) => null,
            retryOnMount: true,
            client: client,
          ),
        );

        // Should retry - fetches should increment
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 2);
        context.dispose();
      });
    });

    test(
        'SHOULD NOT retry on mount '
        'WHEN retryOnMount == false '
        'AND query is in error state', () {
      fakeAsync((async) {
        var fetches = 0;

        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              throw Exception();
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retry: (_, __) => null,
            retryOnMount: false,
            client: client,
          ),
        );

        // Wait for first fetch to fail
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.isError, isTrue);
        expect(fetches, 1);

        // Unmount and remount
        context.dispose();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              throw Exception();
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retry: (_, __) => null,
            retryOnMount: false,
            client: client,
          ),
        );

        // Should NOT retry - fetches should stay the same
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);
        context.dispose();
      });
    });

    test(
        'SHOULD fetch on mount '
        'WHEN retryOnMount == false '
        'AND query has no data', () {
      fakeAsync((async) {
        var fetches = 0;

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            retryOnMount: false,
            client: client,
          ),
        );

        // Should fetch since there's no existing data (not error state)
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(fetches, 1);
        context.dispose();
      });
    });
  });

  group('Params: seed', () {
    test(
        'SHOULD use seed for data'
        '', () async {
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await Future.delayed(const Duration(seconds: 1));
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          seed: const InfiniteData(['page-seed'], [0]),
          client: client,
        ),
      );

      expect(
        context.value.data,
        const InfiniteData(['page-seed'], [0]),
      );
      expect(context.value.dataUpdateCount, 0);
      expect(context.value.isSuccess, isTrue);
      context.dispose();
    });

    test(
        'SHOULD persist seed to cache'
        '', () async {
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await Future.delayed(const Duration(seconds: 1));
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          seed: const InfiniteData(['page-seed'], [0]),
          client: client,
        ),
      );

      expect(
        client.cache.get(const ['test'])?.state.data,
        const InfiniteData(['page-seed'], [0]),
      );
      context.dispose();
    });

    test(
        'SHOULD take precedence over placeholder'
        '', () async {
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await Future.delayed(const Duration(seconds: 1));
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          placeholder: const InfiniteData(['page-ph'], [0]),
          seed: const InfiniteData(['page-seed'], [0]),
          client: client,
        ),
      );

      expect(context.value.data!.pages, ['page-seed']);
      expect(context.value.isPlaceholderData, isFalse);
      context.dispose();
    });

    test(
        'SHOULD be replaced by fetched data'
        '', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            seed: const InfiniteData(['page-seed'], [0]),
            staleDuration: StaleDuration.zero,
            client: client,
          ),
        );

        expect(context.value.data!.pages, ['page-seed']);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data!.pages, ['page-0']);
        context.dispose();
      });
    });
  });

  group('Params: seedUpdatedAt', () {
    test(
        'SHOULD use current time '
        'WHEN seedUpdatedAt is not provided', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            seed: const InfiniteData(['page-seed'], [0]),
            client: client,
          ),
        );

        expect(context.value.dataUpdatedAt, clock.now());
        context.dispose();
      });
    });

    test(
        'SHOULD make data stale '
        'WHEN seedUpdatedAt is older than staleDuration', () async {
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await Future.delayed(const Duration(seconds: 1));
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          seed: const InfiniteData(['page-seed'], [0]),
          seedUpdatedAt: clock.minutesAgo(10),
          staleDuration: const StaleDuration(minutes: 5),
          client: client,
        ),
      );

      expect(context.value.isStale, isTrue);
      context.dispose();
    });

    test(
        'SHOULD NOT make data stale '
        'WHEN seedUpdatedAt is within staleDuration', () async {
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await Future.delayed(const Duration(seconds: 1));
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          seed: const InfiniteData(['page-seed'], [0]),
          seedUpdatedAt: clock.minutesAgo(2),
          staleDuration: const StaleDuration(minutes: 5),
          client: client,
        ),
      );

      expect(context.value.isStale, isFalse);
      context.dispose();
    });

    test(
        'SHOULD extend freshness period '
        'WHEN seedUpdatedAt is set to future DateTime', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            seed: const InfiniteData(['page-seed'], [0]),
            seedUpdatedAt: clock.minutesFromNow(60),
            staleDuration: const StaleDuration(minutes: 5),
            gcDuration: GcDuration.infinity,
            client: client,
          ),
        );

        // Data should NOT be stale (seedUpdatedAt is 1 hour in the future)
        expect(context.value.isStale, isFalse);

        // Even after 30 minutes, data should still be fresh
        context.dispose();
        async.elapse(const Duration(minutes: 30));
        async.flushMicrotasks();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            seed: const InfiniteData(['page-seed'], [0]),
            seedUpdatedAt: clock.minutesFromNow(30),
            staleDuration: const StaleDuration(minutes: 5),
            gcDuration: GcDuration.infinity,
            client: client,
          ),
        );
        expect(context.value.isStale, isFalse);

        // After 1 hour + 5 minutes (seedUpdatedAt + staleDuration), data becomes stale
        context.dispose();
        async.elapse(const Duration(minutes: 35));
        async.flushMicrotasks();
        context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            seed: const InfiniteData(['page-seed'], [0]),
            seedUpdatedAt: clock.minutesAgo(5),
            staleDuration: const StaleDuration(minutes: 5),
            gcDuration: GcDuration.infinity,
            client: client,
          ),
        );
        expect(context.value.isStale, isTrue);
        context.dispose();
      });
    });
  });

  group('Returns: fetchNextPage', () {
    test(
        'SHOULD succeed fetching next page'
        '', () async {
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchNextPage();
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.data, InfiniteData(['page-0'], [0]));

      completers[1].complete();
      await asyncYield();

      expect(context.value.status, QueryStatus.success);
      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, InfiniteData(['page-0', 'page-1'], [0, 1]));
      context.dispose();
    });

    test(
        'SHOULD fail fetching next page'
        '', () async {
      final expectedError = Exception();
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            if (ctx.pageParam == 0) {
              return 'page-${ctx.pageParam}';
            } else {
              throw expectedError;
            }
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchNextPage();
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.error, isNull);

      completers[1].complete();
      await asyncYield();

      expect(context.value.status, QueryStatus.error);
      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.error, same(expectedError));
      context.dispose();
    });

    test(
        'SHOULD NOT fetch more pages '
        'WHEN hasNextPage is false', () async {
      var fetches = 0;
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => null,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(fetches, 1);
      expect(context.value.hasNextPage, isFalse);

      // Try to fetch next page
      context.value.fetchNextPage();
      await asyncYield();

      // Should NOT have fetched again
      expect(fetches, 1);
      context.dispose();
    });

    test(
        'SHOULD respect maxPages limit'
        '', () async {
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          maxPages: 2,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();
      expect(context.value.data, InfiniteData(['page-0'], [0]));

      context.value.fetchNextPage();
      await asyncYield();
      completers[1].complete();
      await asyncYield();
      expect(context.value.data, InfiniteData(['page-0', 'page-1'], [0, 1]));

      context.value.fetchNextPage();
      await asyncYield();
      completers[2].complete();
      await asyncYield();
      expect(context.value.data, InfiniteData(['page-1', 'page-2'], [1, 2]));
      context.dispose();
    });

    test(
        'SHOULD cancel in-progress fetch and start new one '
        'WHEN cancelRefetch == true', () {
      fakeAsync((async) {
        var fetches = 0;
        final fetchNextPageResults = <InfiniteQueryResult<String, Object, int>>[];

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}-fetch-$fetches';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            client: client,
          ),
        );

        // Wait for initial fetch to complete
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.pages, ['page-0-fetch-1']);

        // Call fetchNextPage multiple times rapidly (before previous completes)
        context.value
            .fetchNextPage()
            .then((result) => fetchNextPageResults.add(result));
        context.value
            .fetchNextPage(cancelRefetch: true)
            .then((result) => fetchNextPageResults.add(result));
        context.value
            .fetchNextPage(cancelRefetch: true)
            .then((result) => fetchNextPageResults.add(result));

        // Should have started multiple fetches (cancelling previous ones)
        // but only the last one completes
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.pages, ['page-0-fetch-1', 'page-1-fetch-4']);
        expect(fetchNextPageResults, hasLength(3));
        expect(
          fetchNextPageResults.map((result) => result.pages),
          everyElement(['page-0-fetch-1', 'page-1-fetch-4']),
        );
        context.dispose();
      });
    });

    test(
        'SHOULD return existing promise '
        'WHEN cancelRefetch == false ', () {
      fakeAsync((async) {
        var fetches = 0;
        final fetchNextPageResults = <InfiniteQueryResult<String, Object, int>>[];

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              fetches++;
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}-fetch-$fetches';
            },
            initialPageParam: 0,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            client: client,
          ),
        );

        // Wait for initial fetch to complete
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.pages, ['page-0-fetch-1']);

        // Call fetchNextPage with cancelRefetch: false multiple times
        context.value
            .fetchNextPage()
            .then((result) => fetchNextPageResults.add(result));
        context.value
            .fetchNextPage(cancelRefetch: false)
            .then((result) => fetchNextPageResults.add(result));
        context.value
            .fetchNextPage(cancelRefetch: false)
            .then((result) => fetchNextPageResults.add(result));

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        // Should have fetched only once (deduplication)
        expect(context.value.pages, ['page-0-fetch-1', 'page-1-fetch-2']);
        expect(fetchNextPageResults, hasLength(3));
        expect(
          fetchNextPageResults.map((result) => result.pages),
          everyElement(['page-0-fetch-1', 'page-1-fetch-2']),
        );
        context.dispose();
      });
    });

    test(
        'SHOULD dedupe multiple calls on initial mount'
        '', () async {
      var fetches = 0;
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            fetches++;
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}-fetch-$fetches';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      // Initial fetch is in progress (no data yet)
      expect(context.value.data, isNull);
      expect(context.value.isFetching, isTrue);

      // Try to fetch next page while initial fetch is in progress
      // This should be deduplicated since there's no data yet
      context.value.fetchNextPage();
      context.value.fetchNextPage();

      // Wait for initial fetch to complete
      completers[0].complete();
      await asyncYield();

      // Should only have one fetch (deduplication because no data existed)
      expect(fetches, 1);
      expect(context.value.pages, ['page-0-fetch-1']);
      context.dispose();
    });
  });

  group('Returns: fetchPreviousPage', () {
    test(
        'SHOULD succeed fetching previous page'
        '', () async {
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchPreviousPage();
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.data, InfiniteData(['page-5'], [5]));

      completers[1].complete();
      await asyncYield();

      expect(context.value.status, QueryStatus.success);
      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, InfiniteData(['page-4', 'page-5'], [4, 5]));
      context.dispose();
    });

    test(
        'SHOULD fail fetching previous page'
        '', () async {
      final expectedError = Exception();
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            if (ctx.pageParam == 5) {
              return 'page-${ctx.pageParam}';
            } else {
              throw expectedError;
            }
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchPreviousPage();
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.error, isNull);

      completers[1].complete();
      await asyncYield();

      expect(context.value.status, QueryStatus.error);
      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.error, same(expectedError));
      context.dispose();
    });

    test(
        'SHOULD NOT fetch more pages '
        'WHEN hasPreviousPage is false', () async {
      var fetches = 0;
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            fetches++;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => null,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(fetches, 1);
      expect(context.value.hasPreviousPage, isFalse);

      context.value.fetchPreviousPage();
      await asyncYield();

      expect(fetches, 1);
      context.dispose();
    });

    test(
        'SHOULD respect maxPages limit'
        '', () async {
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          maxPages: 2,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();
      expect(context.value.data, InfiniteData(['page-5'], [5]));

      context.value.fetchPreviousPage();
      await asyncYield();
      completers[1].complete();
      await asyncYield();
      expect(context.value.data, InfiniteData(['page-4', 'page-5'], [4, 5]));

      context.value.fetchPreviousPage();
      await asyncYield();
      completers[2].complete();
      await asyncYield();
      expect(context.value.data, InfiniteData(['page-3', 'page-4'], [3, 4]));
      context.dispose();
    });

    test(
        'SHOULD cancel in-progress fetch and start new one '
        'WHEN cancelRefetch == true', () {
      fakeAsync((async) {
        var fetches = 0;
        final fetchPreviousPageResults =
            <InfiniteQueryResult<String, Object, int>>[];

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              fetches++;
              return 'page-${ctx.pageParam}-fetch-$fetches';
            },
            initialPageParam: 5,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            prevPageParamBuilder: (data) => data.pageParams.first - 1,
            client: client,
          ),
        );

        // Wait for initial fetch to complete
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.pages, ['page-5-fetch-1']);

        // Call fetchNextPage multiple times rapidly (before previous completes)
        context.value
            .fetchPreviousPage()
            .then((result) => fetchPreviousPageResults.add(result));
        context.value
            .fetchPreviousPage(cancelRefetch: true)
            .then((result) => fetchPreviousPageResults.add(result));
        context.value
            .fetchPreviousPage(cancelRefetch: true)
            .then((result) => fetchPreviousPageResults.add(result));

        // Should have started multiple fetches (cancelling previous ones)
        // but only the last one completes
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.pages, ['page-4-fetch-4', 'page-5-fetch-1']);
        expect(fetchPreviousPageResults, hasLength(3));
        expect(
          fetchPreviousPageResults.map((result) => result.pages),
          everyElement(['page-4-fetch-4', 'page-5-fetch-1']),
        );
        context.dispose();
      });
    });

    test(
        'SHOULD return existing promise '
        'WHEN cancelRefetch == false ', () {
      fakeAsync((async) {
        var fetches = 0;
        final fetchPreviousPageResults =
            <InfiniteQueryResult<String, Object, int>>[];

        final context = SimpleHookContext(
          () => useInfiniteQuery<String, Object, int>(
            const ['test'],
            (ctx) async {
              fetches++;
              await Future.delayed(const Duration(seconds: 1));
              return 'page-${ctx.pageParam}-fetch-$fetches';
            },
            initialPageParam: 5,
            nextPageParamBuilder: (data) => data.pageParams.last + 1,
            prevPageParamBuilder: (data) => data.pageParams.first - 1,
            client: client,
          ),
        );

        // Wait for initial fetch to complete
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.pages, ['page-5-fetch-1']);

        // Call fetchNextPage with cancelRefetch: false multiple times
        context.value
            .fetchPreviousPage()
            .then((result) => fetchPreviousPageResults.add(result));
        context.value
            .fetchPreviousPage(cancelRefetch: false)
            .then((result) => fetchPreviousPageResults.add(result));
        context.value
            .fetchPreviousPage(cancelRefetch: false)
            .then((result) => fetchPreviousPageResults.add(result));

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        // Should have fetched only once (deduplication)
        expect(context.value.pages, ['page-4-fetch-2', 'page-5-fetch-1']);
        expect(fetchPreviousPageResults, hasLength(3));
        expect(
          fetchPreviousPageResults.map((result) => result.pages),
          everyElement(['page-4-fetch-2', 'page-5-fetch-1']),
        );
        context.dispose();
      });
    });

    test(
        'SHOULD dedupe multiple calls on initial mount'
        '', () async {
      var fetches = 0;
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            fetches++;
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}-fetch-$fetches';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      // Initial fetch is in progress (no data yet)
      expect(context.value.data, isNull);
      expect(context.value.isFetching, isTrue);

      // Try to fetch next page while initial fetch is in progress
      // This should be deduplicated since there's no data yet
      context.value.fetchPreviousPage();
      context.value.fetchPreviousPage();

      // Wait for initial fetch to complete
      completers[0].complete();
      await asyncYield();

      // Should only have one fetch (deduplication because no data existed)
      expect(fetches, 1);
      expect(context.value.pages, ['page-5-fetch-1']);
      context.dispose();
    });
  });

  group('Returns: hasNextPage', () {
    test(
        'SHOULD return false '
        'WHEN data is null', () async {
      // Case 1: Before fetch completes
      final completer1 = Completer<void>();
      final context1 = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test1'],
          (context) async {
            await completer1.future;
            return 'page-${context.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      expect(context1.value.data, isNull);
      expect(context1.value.hasNextPage, isFalse);

      // Case 2: After initial fetch failed
      final completer2 = Completer<void>();
      final context2 = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test2'],
          (context) async {
            await completer2.future;
            throw Exception();
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completer2.complete();
      await asyncYield();

      expect(context2.value.data, isNull);
      expect(context2.value.hasNextPage, isFalse);
      context1.dispose();
      context2.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN nextPageParamBuilder returns null', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (_) => null,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(context.value.data, isNotNull);
      expect(context.value.hasNextPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return true '
        'WHEN nextPageParamBuilder returns non-null', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(context.value.data, isNotNull);
      expect(context.value.hasNextPage, isTrue);
      context.dispose();
    });
  });

  group('Returns: hasPreviousPage', () {
    test(
        'SHOULD return false '
        'WHEN data is null', () async {
      // Case 1: Before fetch completes
      final completer1 = Completer<void>();
      final context1 = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test1'],
          (context) async {
            await completer1.future;
            return 'page-${context.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      expect(context1.value.data, isNull);
      expect(context1.value.hasPreviousPage, isFalse);

      // Case 2: After initial fetch failed
      final completer2 = Completer<void>();
      final context2 = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test2'],
          (context) async {
            await completer2.future;
            throw Exception();
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completer2.complete();
      await asyncYield();

      expect(context2.value.data, isNull);
      expect(context2.value.hasPreviousPage, isFalse);
      context1.dispose();
      context2.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN prevPageParamBuilder is not provided', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          // prevPageParamBuilder not provided
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(context.value.data, isNotNull);
      expect(context.value.hasPreviousPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN prevPageParamBuilder returns null', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (_) => null,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(context.value.data, isNotNull);
      expect(context.value.hasPreviousPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return true '
        'WHEN prevPageParamBuilder returns non-null', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(context.value.data, isNotNull);
      expect(context.value.hasPreviousPage, isTrue);
      context.dispose();
    });
  });

  group('Returns: isFetchingNextPage', () {
    test(
        'SHOULD return false '
        'WHEN not fetching', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(context.value.isFetchingNextPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN fetching initial page', () async {
      final completer = Completer<void>();
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      expect(context.value.isFetchingNextPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return true '
        'WHEN fetchNextPage is in progress', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchNextPage();
      await asyncYield();

      expect(context.value.isFetchingNextPage, isTrue);
      context.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN fetchPreviousPage is in progress', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchPreviousPage();
      await asyncYield();

      expect(context.value.isFetchingNextPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN refetch is in progress', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.refetch();
      await asyncYield();

      expect(context.value.isFetchingNextPage, isFalse);
      context.dispose();
    });
  });

  group('Returns: isFetchingPreviousPage', () {
    test(
        'SHOULD return false '
        'WHEN not fetching', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      expect(context.value.isFetchingPreviousPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN fetching initial page', () async {
      final completer = Completer<void>();
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            await completer.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      expect(context.value.isFetchingPreviousPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN fetchNextPage is in progress', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchNextPage();
      await asyncYield();

      expect(context.value.isFetchingPreviousPage, isFalse);
      context.dispose();
    });

    test(
        'SHOULD return true '
        'WHEN fetchPreviousPage is in progress', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.fetchPreviousPage();
      await asyncYield();

      expect(context.value.isFetchingPreviousPage, isTrue);
      context.dispose();
    });

    test(
        'SHOULD return false '
        'WHEN refetch is in progress', () async {
      final completers = <Completer<void>>[];
      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            return 'page-${ctx.pageParam}';
          },
          initialPageParam: 5,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          prevPageParamBuilder: (data) => data.pageParams.first - 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();

      context.value.refetch();
      await asyncYield();

      expect(context.value.isFetchingPreviousPage, isFalse);
      context.dispose();
    });
  });

  group('Returns: refetch', () {
    test(
        'SHOULD refetch all existing pages sequentially'
        '', () async {
      var fetches = 0;
      final completers = <Completer<void>>[];

      final context = SimpleHookContext(
        () => useInfiniteQuery<String, Object, int>(
          const ['test'],
          (ctx) async {
            final c = Completer<void>();
            completers.add(c);
            await c.future;
            fetches++;
            return 'page-${ctx.pageParam}:fetches-$fetches';
          },
          initialPageParam: 0,
          nextPageParamBuilder: (data) => data.pageParams.last + 1,
          client: client,
        ),
      );

      completers[0].complete();
      await asyncYield();
      expect(fetches, 1);

      context.value.fetchNextPage();
      await asyncYield();
      completers[1].complete();
      await asyncYield();
      expect(fetches, 2);
      expect(
        context.value.data,
        InfiniteData(['page-0:fetches-1', 'page-1:fetches-2'], [0, 1]),
      );

      // Refetch all pages
      context.value.refetch();
      await asyncYield();
      completers[2].complete();
      await asyncYield();

      // First page refetched, still fetching second page
      expect(fetches, 3);
      expect(context.value.isFetching, isTrue);

      completers[3].complete();
      await asyncYield();

      // All pages refetched
      expect(fetches, 4);
      expect(context.value.isFetching, isFalse);
      expect(
        context.value.data,
        InfiniteData(['page-0:fetches-3', 'page-1:fetches-4'], [0, 1]),
      );
      context.dispose();
    });
  });

  group('Parameter: networkMode', () {
    late StreamController<bool> connectivityController;

    setUp(() {
      connectivityController = StreamController<bool>();
      client = QueryClient(
        connectivityChanges: connectivityController.stream,
      );
    });

    tearDown(() {
      client.clear();
      connectivityController.close();
    });

    group('== NetworkMode.online', () {
      // Pauses when offline, resumes when online

      test(
          'SHOULD fetch normally online'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'page-0';
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.online,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data?.pages, ['page-0']);
          context.dispose();
        });
      });

      test(
          'SHOULD pause offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          // Start offline
          connectivityController.add(false);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'page-0';
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.online,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.paused);
          expect(context.value.isPaused, isTrue);

          // Should be kept paused
          async.elapse(const Duration(days: 365));
          async.flushMicrotasks();
          expect(context.value.fetchStatus, FetchStatus.paused);
          expect(context.value.isPaused, isTrue);

          // Go online
          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data?.pages, ['page-0']);
          context.dispose();
        });
      });

      test(
          'SHOULD pause retries on going offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          var queryFnCount = 0;
          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                queryFnCount++;
                throw Exception();
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.online,
              retry: (retryCount, _) {
                if (retryCount < 3) {
                  return const Duration(seconds: 1);
                }
                return null;
              },
              client: client,
            ),
          );

          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(queryFnCount, 1);

          // Go offline
          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(queryFnCount, 1);

          // Go online
          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(queryFnCount, 2);

          // Wait for remaining retries to complete
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(queryFnCount, 3);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(queryFnCount, 4);
          expect(context.value.status, QueryStatus.error);
          context.dispose();
        });
      });
    });

    group('== NetworkMode.always', () {
      // Never pauses, ignores network state

      test(
          'SHOULD fetch normally online'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'page-0';
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.always,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data?.pages, ['page-0']);
          context.dispose();
        });
      });

      test(
          'SHOULD fetch normally offline'
          '', () {
        fakeAsync((async) {
          // Start offline
          connectivityController.add(false);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'page-0';
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.always,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data?.pages, ['page-0']);
          context.dispose();
        });
      });

      test(
          'SHOULD NOT pause on going offline'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'page-0';
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.always,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          // Go offline
          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data?.pages, ['page-0']);
          context.dispose();
        });
      });

      test(
          'SHOULD NOT pause retries on going offline'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          var queryFnCount = 0;
          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                queryFnCount++;
                throw Exception();
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.always,
              retry: (retryCount, _) {
                if (retryCount < 3) {
                  return const Duration(seconds: 1);
                }
                return null;
              },
              client: client,
            ),
          );

          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(queryFnCount, 1);

          // Go offline
          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(queryFnCount, 1);

          // Should continue retrying
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(queryFnCount, 2);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(queryFnCount, 3);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(queryFnCount, 4);
          expect(context.value.status, QueryStatus.error);
          context.dispose();
        });
      });
    });

    group('== NetworkMode.offlineFirst', () {
      // Always runs first execution, pauses retries offline

      test(
          'SHOULD execute initial fetch normally online'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'page-0';
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.offlineFirst,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data?.pages, ['page-0']);
          context.dispose();
        });
      });

      test(
          'SHOULD execute initial fetch normally offline'
          '', () {
        fakeAsync((async) {
          // Start offline
          connectivityController.add(false);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'page-0';
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.offlineFirst,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data?.pages, ['page-0']);
          context.dispose();
        });
      });

      test(
          'SHOULD pause retries offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          // Start offline
          connectivityController.add(false);
          async.flushMicrotasks();

          var queryFnCount = 0;
          final context = SimpleHookContext(
            () => useInfiniteQuery<String, Object, int>(
              const ['key'],
              (_) async {
                queryFnCount++;
                throw Exception();
              },
              initialPageParam: 0,
              nextPageParamBuilder: (data) => data.pageParams.last + 1,
              networkMode: NetworkMode.offlineFirst,
              retry: (retryCount, _) {
                if (retryCount < 3) {
                  return const Duration(seconds: 1);
                }
                return null;
              },
              client: client,
            ),
          );

          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(context.value.failureCount, 1);
          expect(queryFnCount, 1);

          // Should NOT retry when paused
          async.elapse(const Duration(days: 365));
          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(queryFnCount, 1);

          // Go online
          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(queryFnCount, 2);

          // Should continue retrying
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(queryFnCount, 3);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(queryFnCount, 4);
          expect(context.value.status, QueryStatus.error);
          context.dispose();
        });
      });
    });
  });
}
