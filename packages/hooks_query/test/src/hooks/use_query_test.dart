import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_query/src/core/core.dart';
import 'package:utopia_hooks_query/src/hooks/hooks.dart';

import '../../utils.dart';

Type _typeOf<T>() => T;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QueryClient client;

  setUp(() {
    client = QueryClient();
    // Reset the app lifecycle to a non-resumed baseline so that the resume
    // tests below observe a real inactive -> resumed transition. The binding's
    // lifecycle state is global and leaks between tests, so without this a
    // prior test that resumed the app would suppress later onResume callbacks.
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
  });

  tearDown(() {
    client.clear();
  });

  test('SHOULD fetch and succeed', () async {
    final data = Object();

    final completer = Completer<Object>();
    final context = SimpleHookContext(() {
      return useQuery(
        const ['key'],
        (context) async => completer.future,
        client: client,
      );
    });

    var result = context();
    expect(result.status, QueryStatus.pending);
    expect(result.fetchStatus, FetchStatus.fetching);
    expect(result.data, null);
    expect(result.dataUpdatedAt, null);
    expect(result.error, null);
    expect(result.errorUpdatedAt, null);
    expect(result.errorUpdateCount, 0);
    expect(result.failureCount, 0);
    expect(result.failureReason, null);
    expect(result.isEnabled, true);

    final updatedAt = clock.now();
    completer.complete(data);
    await asyncYield();

    result = context();
    expect(result.status, QueryStatus.success);
    expect(result.fetchStatus, FetchStatus.idle);
    expect(result.data, same(data));
    expect(result.dataUpdatedAt, after(updatedAt));
    expect(result.error, null);
    expect(result.errorUpdatedAt, null);
    expect(result.errorUpdateCount, 0);
    expect(result.failureCount, 0);
    expect(result.failureReason, null);
    expect(result.isEnabled, true);
  });

  test('SHOULD fetch and fail', () async {
    final error = Exception();
    final completer = Completer<String>();

    final context = SimpleHookContext(
      () => useQuery<String, Object>(
        const ['key'],
        (context) async => completer.future,
        retry: (_, __) => null,
        client: client,
      ),
    );

    var result = context.value;
    expect(result.status, QueryStatus.pending);
    expect(result.fetchStatus, FetchStatus.fetching);
    expect(result.data, null);
    expect(result.dataUpdatedAt, null);
    expect(result.error, null);
    expect(result.errorUpdatedAt, null);
    expect(result.errorUpdateCount, 0);
    expect(result.failureCount, 0);
    expect(result.failureReason, null);
    expect(result.isEnabled, true);

    final startedAt = clock.now();
    completer.completeError(error);
    await asyncYield();

    result = context.value;
    expect(result.status, QueryStatus.error);
    expect(result.fetchStatus, FetchStatus.idle);
    expect(result.data, null);
    expect(result.dataUpdatedAt, null);
    expect(result.error, same(error));
    expect(result.errorUpdatedAt, after(startedAt));
    expect(result.errorUpdateCount, 1);
    expect(result.failureCount, 1);
    expect(result.failureReason, same(error));
    expect(result.isEnabled, true);
    context.dispose();
  });

  test('SHOULD pass QueryFunctionContext to queryFn', () async {
    QueryFunctionContext? capturedContext;
    final queryKey = ['users', 123];

    final context = SimpleHookContext(
      () => useQuery(
        queryKey,
        (ctx) async {
          capturedContext = ctx;
          return 'data';
        },
        client: client,
      ),
    );

    await asyncYield();

    expect(capturedContext, isNotNull);
    expect(capturedContext!.queryKey, equals(queryKey));
    expect(capturedContext!.client, same(client));
    context.dispose();
  });

  test('SHOULD fetch and succeed (synchronous queryFn)', () async {
    final data = Object();

    final context = SimpleHookContext(
      () => useQuery(
        const ['key'],
        (ctx) async => data,
        client: client,
      ),
    );

    var result = context.value;
    expect(result.status, QueryStatus.pending);
    expect(result.fetchStatus, FetchStatus.fetching);
    expect(result.data, null);

    await asyncYield();

    result = context.value;
    expect(result.status, QueryStatus.success);
    expect(result.fetchStatus, FetchStatus.idle);
    expect(result.data, same(data));
    context.dispose();
  });

  test('SHOULD fetch only once WHEN multiple hooks share same key', () async {
    var fetchCount = 0;
    final context1 = SimpleHookContext(
      () => useQuery(["key"], (context) async => 'data-${++fetchCount}', client: client),
    );
    final context2 = SimpleHookContext(
      () => useQuery(["key"], (context) async => 'data-${++fetchCount}', client: client),
    );

    expect(context1.value.data, null);
    expect(context2.value.data, null);

    await asyncYield();

    expect(context1.value.data, 'data-1');
    expect(context2.value.data, 'data-1');
    context1.dispose();
    context2.dispose();
  });

  test('SHOULD fetch fresh WHEN queryKey changes', () async {
    var key = const <Object?>['key1'];
    final context = SimpleHookContext(
      () => useQuery<String, Object>(
        key,
        (ctx) async => 'data-$key',
        client: client,
      ),
    );

    expect(context.value.data, null);

    await asyncYield();

    expect(context.value.data, 'data-[key1]');

    key = const ['key2'];
    context.rebuild();

    expect(context.value.data, null);

    await asyncYield();

    expect(context.value.data, 'data-[key2]');
    context.dispose();
  });

  test('SHOULD clean up observers on unmount', () async {
    final context = SimpleHookContext(
      () => useQuery(
        const ['key'],
        (ctx) async => 'data',
        client: client,
      ),
    );

    await asyncYield();

    final query = client.cache.get(const ['key'])!;

    expect(query.hasObservers, true);

    context.dispose();

    expect(query.hasObservers, false);
  });

  test('SHOULD distinguish between different query keys', () async {
    final context1 = SimpleHookContext(
      () => useQuery(const ['key1'], (context) async => 'data1', client: client),
    );
    final context2 = SimpleHookContext(
      () => useQuery(const ['key2'], (context) async => 'data2', client: client),
    );

    await asyncYield();

    expect(context1.value.data, 'data1');
    expect(context2.value.data, 'data2');
    context1.dispose();
    context2.dispose();
  });

  group('enabled', () {
    test('SHOULD NOT fetch WHEN enabled is false', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          enabled: false,
          client: client,
        ),
      );

      await asyncYield();

      expect(context.value.status, QueryStatus.pending);
      expect(context.value.data, null);
      context.dispose();
    });

    test('SHOULD fetch WHEN enabled changes from false to true', () async {
      var enabled = false;
      final completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => completer.future,
          enabled: enabled,
          client: client,
        ),
      );

      await asyncYield();

      expect(context.value.status, QueryStatus.pending);
      expect(context.value.data, null);

      enabled = true;
      context.rebuild();

      expect(context.value.fetchStatus, FetchStatus.fetching);

      completer.complete('data');
      await asyncYield();

      expect(context.value.status, QueryStatus.success);
      expect(context.value.data, 'data');
      context.dispose();
    });
  });

  group('staleDuration', () {
    test('SHOULD mark data as stale WHEN staleDuration is zero', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.zero,
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.isStale, true);
        context.dispose();
      });
    });

    test('SHOULD mark data as fresh WHEN within staleDuration', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: const StaleDuration(minutes: 5),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.isStale, false);

        async.elapse(const Duration(minutes: 3));
        async.flushMicrotasks();

        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD update isStale WHEN staleDuration changes', () {
      fakeAsync((async) {
        var staleDuration = const StaleDuration(minutes: 5);
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: staleDuration,
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.isStale, false);

        staleDuration = const StaleDuration();
        context.rebuild();
        expect(context.value.isStale, true);

        staleDuration = const StaleDuration(minutes: 10);
        context.rebuild();
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD refetch WHEN staleDuration changes and data becomes stale', () {
      fakeAsync((async) {
        var staleDuration = const StaleDuration(minutes: 5);
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: staleDuration,
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        async.elapse(const Duration(minutes: 1));
        staleDuration = const StaleDuration(seconds: 30);
        context.rebuild();

        expect(context.value.fetchStatus, FetchStatus.fetching);
        expect(context.value.isStale, true);

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD NOT refetch WHEN staleDuration changes and data remains fresh', () {
      fakeAsync((async) {
        var staleDuration = const StaleDuration(minutes: 5);
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: staleDuration,
            client: client,
          ),
          shouldRebuild: false,
        );

        async.flushTimers();
        async.flushMicrotasks();

        async.elapse(const Duration(minutes: 8));
        staleDuration = const StaleDuration(minutes: 10);
        context.rebuild();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD refetch on mount WHEN data becomes stale', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: const StaleDuration(minutes: 5),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        context.dispose();

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: const StaleDuration(minutes: 5),
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.fetching);
        expect(context.value.isStale, true);

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD NOT refetch WHEN data is fresh on mount', () {
      fakeAsync((async) {
        final query = Query<String, Object>.cached(client, const ['key']);
        query.fetch((ctx) async => 'initial').ignore();
        async.flushMicrotasks();

        final context = SimpleHookContext(
          () => useQuery<String, Object>(
            ['key'],
            (ctx) async => 'data',
            staleDuration: const StaleDuration(minutes: 5),
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'initial');
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD NOT mark data as stale WHEN using never', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.static,
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.data, 'data');
        expect(context.value.isStale, false);

        async.elapse(const Duration(hours: 24));
        async.flushMicrotasks();

        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD NOT refetch on mount WHEN using never and time passed was shorter than gcDuration', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.static,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        context.dispose();
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.static,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data');
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD refetch on mount WHEN using never and time passed was longer than gcDuration', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.static,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        context.dispose();
        async.elapse(const Duration(minutes: 10));
        async.flushMicrotasks();

        context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.static,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.fetching);
        expect(context.value.isStale, true);

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.data, 'data');
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD NOT mark data as stale WHEN using StaleDuration.infinity', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.infinity,
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.data, 'data');
        expect(context.value.isStale, false);

        async.elapse(const Duration(hours: 24));
        async.flushMicrotasks();

        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD NOT refetch on mount WHEN using StaleDuration.infinity and time passed was shorter than gcDuration',
        () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.infinity,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        context.dispose();
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.infinity,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data');
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD refetch on mount WHEN using StaleDuration.infinity and time passed was longer than gcDuration', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.infinity,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        context.dispose();
        async.elapse(const Duration(minutes: 10));
        async.flushMicrotasks();

        context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async => 'data',
            staleDuration: StaleDuration.infinity,
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.fetching);
        expect(context.value.isStale, true);

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.data, 'data');
        expect(context.value.isStale, false);
        context.dispose();
      });
    });

    test('SHOULD default to zero WHEN staleDuration is not specified', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.isStale, true);
        context.dispose();
      });
    });
  });

  group('refetchOnMount', () {
    test('SHOULD refetch on mount WHEN set to stale AND data is stale', () async {
      var context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.stale,
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      await asyncYield();

      context.dispose();

      context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.stale,
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.isStale, true);
      context.dispose();
    });

    test('SHOULD NOT refetch on mount WHEN set to stale AND data is fresh', () async {
      var context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.stale,
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      await asyncYield();

      context.dispose();

      context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.stale,
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.isStale, false);
      context.dispose();
    });

    test('SHOULD NOT refetch on mount WHEN set to never even if data is stale', () async {
      var context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.never,
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      await asyncYield();

      context.dispose();

      context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.never,
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.isStale, true);
      context.dispose();
    });

    test('SHOULD fetch on mount WHEN no data even if refetchOnMount is never', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.never,
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.fetching);

      await asyncYield();

      expect(context.value.data, 'data');
      context.dispose();
    });

    test('SHOULD refetch on mount WHEN set to always even if data is fresh', () async {
      var context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.always,
          staleDuration: const StaleDuration(minutes: 5),
          client: client,
        ),
      );

      await asyncYield();

      context.dispose();

      context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.always,
          staleDuration: const StaleDuration(minutes: 5),
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.isStale, false);
      context.dispose();
    });

    test('SHOULD NOT refetch on mount WHEN set to always AND staleDuration is static', () async {
      var context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.always,
          staleDuration: StaleDuration.static,
          client: client,
        ),
      );

      await asyncYield();

      context.dispose();

      context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          refetchOnMount: RefetchOnMount.always,
          staleDuration: StaleDuration.static,
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.isStale, false);
      context.dispose();
    });
  });

  group('refetchOnResume == RefetchOnResume.stale', () {
    test('SHOULD refetch WHEN data is stale', () async {
      var fetchCount = 0;
      var completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => completer.future,
          refetchOnResume: RefetchOnResume.stale,
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      completer.complete('data-${++fetchCount}');
      await asyncYield();

      expect(context.value.data, 'data-1');
      expect(context.value.isStale, isTrue);

      completer = Completer<String>();
      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);

      completer.complete('data-${++fetchCount}');
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-2');
      context.dispose();
    });

    test('SHOULD NOT refetch WHEN data is fresh', () async {
      var fetchCount = 0;
      final completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => completer.future,
          refetchOnResume: RefetchOnResume.stale,
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      completer.complete('data-${++fetchCount}');
      await asyncYield();

      expect(context.value.data, 'data-1');
      expect(context.value.isStale, isFalse);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-1');
      context.dispose();
    });

    test('SHOULD refetch WHEN data is stale (with synchronous queryFn)', () async {
      var fetchCount = 0;
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => 'data-${++fetchCount}',
          refetchOnResume: RefetchOnResume.stale,
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      await asyncYield();

      expect(context.value.data, 'data-1');
      expect(context.value.isStale, isTrue);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-2');
      context.dispose();
    });

    test('SHOULD NOT refetch WHEN data is fresh (with synchronous queryFn)', () async {
      var fetchCount = 0;
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => 'data-${++fetchCount}',
          refetchOnResume: RefetchOnResume.stale,
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      await asyncYield();

      expect(context.value.data, 'data-1');
      expect(context.value.isStale, isFalse);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-1');
      context.dispose();
    });
  });

  group('refetchOnResume == RefetchOnResume.never', () {
    test('SHOULD NOT refetch on resumed WHEN data is stale', () async {
      var fetchCount = 0;
      final completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => completer.future,
          refetchOnResume: RefetchOnResume.never,
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      completer.complete('data-${++fetchCount}');
      await asyncYield();

      expect(context.value.data, 'data-1');
      expect(context.value.isStale, isTrue);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-1');
      context.dispose();
    });

    test('SHOULD NOT fetch on resumed WHEN query is in error state with no data', () async {
      var fetchCount = 0;
      final completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => completer.future,
          refetchOnResume: RefetchOnResume.never,
          retry: (_, __) => null,
          client: client,
        ),
      );

      fetchCount++;
      completer.completeError(Exception());
      await asyncYield();

      expect(context.value.status, QueryStatus.error);
      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, isNull);
      expect(fetchCount, 1);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(fetchCount, 1);
      context.dispose();
    });
  });

  group('refetchOnResume == RefetchOnResume.always', () {
    test('SHOULD refetch on mount WHEN data is fresh', () async {
      var fetchCount = 0;
      var completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => completer.future,
          refetchOnResume: RefetchOnResume.always,
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      fetchCount++;
      completer.complete('data-$fetchCount');
      await asyncYield();

      expect(context.value.data, 'data-1');
      expect(context.value.isStale, isFalse);

      completer = Completer<String>();
      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);

      fetchCount++;
      completer.complete('data-$fetchCount');
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-2');
      context.dispose();
    });

    test('SHOULD NOT refetch on mount WHEN staleDuration is static', () async {
      var fetchCount = 0;
      final completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => completer.future,
          refetchOnResume: RefetchOnResume.always,
          staleDuration: StaleDuration.static,
          client: client,
        ),
      );

      fetchCount++;
      completer.complete('data-$fetchCount');
      await asyncYield();

      expect(context.value.data, 'data-1');
      expect(context.value.isStale, isFalse);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-1');
      context.dispose();
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
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data-${++fetches}';
            },
            staleDuration: StaleDuration.zero,
            refetchOnReconnect: RefetchOnReconnect.stale,
            client: reconnectClient,
          ),
        );

        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data, 'data-1');
        expect(context.value.isStale, isTrue);

        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.fetching);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data-2');
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
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data-${++fetches}';
            },
            staleDuration: StaleDuration.infinity,
            refetchOnReconnect: RefetchOnReconnect.stale,
            client: reconnectClient,
          ),
        );

        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data, 'data-1');
        expect(context.value.isStale, isFalse);

        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data-1');
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
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data-${++fetches}';
            },
            staleDuration: StaleDuration.zero,
            refetchOnReconnect: RefetchOnReconnect.never,
            client: reconnectClient,
          ),
        );

        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data, 'data-1');
        expect(context.value.isStale, isTrue);

        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data-1');

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data-1');
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
          () => useQuery(
            const ['key'],
            (ctx) async {
              fetches++;
              await Future.delayed(const Duration(seconds: 1));
              return 'data-$fetches';
            },
            refetchOnReconnect: RefetchOnReconnect.always,
            staleDuration: StaleDuration.infinity,
            client: reconnectClient,
          ),
        );

        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data, 'data-1');
        expect(context.value.isStale, isFalse);

        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.fetching);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data-2');
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
          () => useQuery(
            const ['key'],
            (ctx) async {
              fetches++;
              await Future.delayed(const Duration(seconds: 1));
              return 'data-$fetches';
            },
            staleDuration: StaleDuration.static,
            refetchOnReconnect: RefetchOnReconnect.always,
            client: reconnectClient,
          ),
        );

        connectivityController.add(true);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.data, 'data-1');
        expect(context.value.isStale, isFalse);

        connectivityController.add(false);
        async.flushMicrotasks();
        connectivityController.add(true);
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data-1');

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'data-1');
        context.dispose();
      });
    });
  });

  group('gcDuration', () {
    test('SHOULD remove cache WHEN time passes gcDuration', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            gcDuration: const GcDuration(minutes: 5),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNotNull);

        context.dispose();

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNull);
      });
    });

    test('SHOULD NOT remove cache WHEN gcDuration is infinity', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            gcDuration: GcDuration.infinity,
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNotNull);

        context.dispose();

        async.elapse(const Duration(hours: 24));
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNotNull);
      });
    });

    test('SHOULD NOT remove cache WHEN another hook is still subscribed', () {
      fakeAsync((async) {
        final context1 = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (context) async => 'data-1',
            gcDuration: const GcDuration(minutes: 5),
            client: client,
          ),
        );
        final context2 = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (context) async => 'data-2',
            gcDuration: const GcDuration(minutes: 5),
            client: client,
          ),
        );

        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNotNull);

        // Dispose context1, context2 still subscribed
        context1.dispose();

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNotNull);

        // Dispose context2 — no more subscribers
        context2.dispose();

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNull);
      });
    });

    test('SHOULD default to 5 mins WHEN gcDuration is not specified', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNotNull);

        context.dispose();

        for (var i = 0; i < 5; i++) {
          expect(client.cache.get(const ['key']), isNotNull);
          async.elapse(const Duration(minutes: 1));
          async.flushMicrotasks();
        }

        expect(client.cache.get(const ['key']), isNull);
      });
    });

    test('SHOULD cancel gc timer WHEN hook resubscribes', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        async.flushTimers();
        async.flushMicrotasks();

        context.dispose();

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            gcDuration: const GcDuration(minutes: 10),
            client: client,
          ),
        );

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(client.cache.get(const ['key']), isNotNull);
        context.dispose();
      });
    });
  });

  group('queryClient', () {
    test('SHOULD find QueryClient provided by QueryClientProvider', () async {
      final context = SimpleHookContext(
        () => useQuery(const ['key'], (context) async => 'data'),
        provided: {_typeOf<QueryClient Function()>(): () => client},
      );

      await asyncYield();

      expect(context.value.data, equals('data'));
      context.dispose();
    });

    test('SHOULD prioritize queryClient over QueryClientProvider', () async {
      final prioritizedQueryClient = QueryClient();
      addTearDown(prioritizedQueryClient.clear);

      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (context) async => 'data',
          client: prioritizedQueryClient,
        ),
        provided: {_typeOf<QueryClient Function()>(): () => client},
      );

      await asyncYield();

      expect(prioritizedQueryClient.cache.get(const ['key']), isNotNull);
      expect(client.cache.get(const ['key']), isNull);
      context.dispose();
    });

    test('SHOULD throw WHEN QueryClient is not provided', () {
      expect(
        () => SimpleHookContext(
          () => useQuery<String, Object>(const ['test'], (context) async => 'data'),
        ),
        throwsA(isA<FlutterError>()),
      );
    });
  });

  group('seed', () {
    test('SHOULD start with success status WHEN seed is provided', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          seed: 'initial-data',
          client: client,
        ),
      );

      final result = context.value;
      expect(result.status, QueryStatus.success);
      expect(result.data, 'initial-data');
      context.dispose();
    });

    test('SHOULD refetch WHEN seed is stale', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          seed: 'initial-data',
          staleDuration: const StaleDuration(),
          client: client,
        ),
      );

      expect(context.value.data, 'initial-data');
      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.isStale, true);

      await asyncYield();

      expect(context.value.data, 'data');
      context.dispose();
    });

    test('SHOULD NOT refetch WHEN seed is fresh', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          seed: 'initial-data',
          staleDuration: const StaleDuration(minutes: 5),
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.isStale, false);

      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'initial-data');
      expect(context.value.isStale, false);
      context.dispose();
    });

    test('SHOULD update initialData WHEN Query exists without data and observer is created with seed', () async {
      final completer = Completer<String>();
      final context1 = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => completer.future,
          client: client,
        ),
      );

      expect(context1.value.status, QueryStatus.pending);
      expect(context1.value.fetchStatus, FetchStatus.fetching);
      expect(context1.value.data, null);

      context1.dispose();

      final context2 = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data-2',
          seed: 'initial-data',
          client: client,
        ),
      );

      expect(context2.value.status, QueryStatus.success);
      expect(context2.value.data, 'initial-data');

      completer.complete('data-1');
      await asyncYield();
      context2.dispose();
    });
  });

  group('seedUpdatedAt', () {
    test('SHOULD use current time WHEN seedUpdatedAt is not set', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            seed: 'initial-data',
            client: client,
          ),
        );

        expect(context.value.dataUpdatedAt, clock.now());
        context.dispose();
      });
    });

    test('SHOULD use provided time WHEN seedUpdatedAt is set', () async {
      final specificTime = DateTime(2025, 1, 1, 12, 0, 0);

      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          seed: 'initial-data',
          seedUpdatedAt: specificTime,
          client: client,
        ),
      );

      expect(context.value.dataUpdatedAt, specificTime);
      context.dispose();
    });

    test('SHOULD determine staleness based on seedUpdatedAt and staleDuration', () async {
      var context = SimpleHookContext(
        () => useQuery(
          const ['key', 1],
          (ctx) async => 'data',
          seed: 'initial-data',
          seedUpdatedAt: clock.minutesAgo(10),
          staleDuration: const StaleDuration(minutes: 5),
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.isStale, true);
      context.dispose();

      context = SimpleHookContext(
        () => useQuery(
          const ['key', 2],
          (ctx) async => 'data',
          seed: 'initial-data',
          seedUpdatedAt: clock.minutesAgo(10),
          staleDuration: const StaleDuration(minutes: 15),
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.isStale, false);
      context.dispose();
    });

    test('SHOULD refetch on mount WHEN seed becomes stale over time', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            seed: 'initial-data',
            seedUpdatedAt: clock.minutesAgo(5),
            staleDuration: const StaleDuration(minutes: 10),
            gcDuration: GcDuration.infinity,
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.idle);
        expect(context.value.data, 'initial-data');

        context.dispose();

        async.elapse(const Duration(minutes: 10));
        async.flushMicrotasks();

        context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async => 'data',
            seed: 'initial-data',
            seedUpdatedAt: clock.minutesAgo(15),
            staleDuration: const StaleDuration(minutes: 10),
            gcDuration: GcDuration.infinity,
            client: client,
          ),
        );

        expect(context.value.fetchStatus, FetchStatus.fetching);

        async.flushTimers();
        async.flushMicrotasks();

        expect(context.value.data, 'data');
        context.dispose();
      });
    });
  });

  group('placeholder', () {
    test('SHOULD show placeholder data', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          placeholder: 'placeholder',
          client: client,
        ),
      );

      final result = context.value;
      expect(result.status, QueryStatus.success);
      expect(result.fetchStatus, FetchStatus.fetching);
      expect(result.data, 'placeholder');
      expect(result.isPlaceholderData, true);
      context.dispose();
    });

    test('SHOULD replace placeholder data once fetch completes', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          placeholder: 'placeholder',
          client: client,
        ),
      );

      expect(context.value.data, 'placeholder');
      expect(context.value.isPlaceholderData, true);

      await asyncYield();

      expect(context.value.data, 'data');
      expect(context.value.isPlaceholderData, false);
      context.dispose();
    });

    test('SHOULD show placeholder data WHEN enabled is false', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          placeholder: 'placeholder',
          enabled: false,
          client: client,
        ),
      );

      final result = context.value;
      expect(result.status, QueryStatus.success);
      expect(result.fetchStatus, FetchStatus.idle);
      expect(result.data, 'placeholder');
      expect(result.isEnabled, false);
      expect(result.isPlaceholderData, true);
      context.dispose();
    });

    test('SHOULD NOT show placeholder WHEN query already has data', () async {
      final query = Query<String, Object>.cached(client, const ['key']);
      query.fetch((ctx) async => 'data-cached').ignore();
      await asyncYield();

      final context = SimpleHookContext(
        () => useQuery<String, Object>(
          const ['key'],
          (ctx) async => 'data',
          placeholder: 'placeholder',
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      expect(context.value.data, 'data-cached');
      expect(context.value.isPlaceholderData, false);
      context.dispose();
    });

    test('SHOULD NOT show placeholder data WHEN seed is provided', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          seed: 'initial',
          placeholder: 'placeholder',
          client: client,
        ),
      );

      final result = context.value;
      expect(result.status, QueryStatus.success);
      expect(result.fetchStatus, FetchStatus.fetching);
      expect(result.data, 'initial');
      expect(result.isPlaceholderData, false);
      context.dispose();
    });

    test('SHOULD NOT persist placeholder data to cache', () async {
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => 'data',
          placeholder: 'placeholder',
          client: client,
        ),
      );

      expect(context.value.data, 'placeholder');
      expect(context.value.isPlaceholderData, true);

      final query = client.cache.get(const ['key'])!;
      expect(query.state.data, isNot('placeholder'));
      context.dispose();
    });

    test('SHOULD replace with new placeholder data WHEN fetch has not completed', () async {
      final completer = Completer<String>();
      var placeholder = 'placeholder-1';
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => completer.future,
          placeholder: placeholder,
          client: client,
        ),
        shouldRebuild: false,
      );

      expect(context.value.data, 'placeholder-1');
      expect(context.value.isPlaceholderData, true);

      placeholder = 'placeholder-2';
      context.rebuild();

      expect(context.value.data, 'placeholder-2');
      expect(context.value.isPlaceholderData, true);
      context.dispose();
    });
  });

  group('refetchInterval', () {
    test('SHOULD refetch at interval', () {
      fakeAsync((async) {
        final start = clock.now();
        var fetchAttempts = 0;

        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              fetchAttempts++;
              await Future.delayed(const Duration(seconds: 3));
              return 'data-$fetchAttempts';
            },
            refetchInterval: const Duration(seconds: 10),
            client: client,
          ),
        );
        expect(context.value.isLoading, isTrue);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(context.value.isFetched, isTrue);
        expect(fetchAttempts, 1);

        for (var i = 2; i < 20; i++) {
          async.elapse(start.add(Duration(seconds: 10 * (i - 1))).difference(clock.now()));
          async.flushMicrotasks();
          expect(context.value.isRefetching, isTrue);
          expect(fetchAttempts, i);

          async.elapse(const Duration(seconds: 3));
          async.flushMicrotasks();
          expect(context.value.data, 'data-$i');
          expect(
            context.value.dataUpdatedAt,
            start.add(Duration(seconds: 10 * (i - 1) + 3)),
          );
        }
        context.dispose();
      });
    });

    test('SHOULD reschedule refetch WHEN interval duration changes', () {
      fakeAsync((async) {
        final start = clock.now();
        var fetchAttempts = 0;
        var interval = const Duration(seconds: 10);

        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              fetchAttempts++;
              await Future.delayed(const Duration(seconds: 3));
              return 'data-$fetchAttempts';
            },
            refetchInterval: interval,
            client: client,
          ),
        );
        expect(context.value.isLoading, isTrue);
        expect(fetchAttempts, 1);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(context.value.data, 'data-1');
        expect(context.value.dataUpdatedAt, start.add(const Duration(seconds: 3)));

        async.elapse(start.add(const Duration(seconds: 10)).difference(clock.now()));
        async.flushMicrotasks();
        expect(context.value.isRefetching, isTrue);
        expect(fetchAttempts, 2);

        interval = const Duration(seconds: 5);
        context.rebuild();

        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        expect(context.value.isRefetching, isTrue);
        expect(fetchAttempts, 3);

        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        expect(context.value.isRefetching, isTrue);
        expect(fetchAttempts, 4);
        context.dispose();
      });
    });

    test('SHOULD NOT refetch at interval WHEN enabled is false', () {
      fakeAsync((async) {
        var fetchAttempts = 0;

        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              fetchAttempts++;
              await Future.delayed(const Duration(seconds: 3));
              return 'data-$fetchAttempts';
            },
            enabled: false,
            refetchInterval: const Duration(seconds: 10),
            client: client,
          ),
        );

        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        expect(context.value.isFetched, isFalse);
        expect(context.value.isRefetching, isFalse);
        expect(fetchAttempts, 0);
        context.dispose();
      });
    });

    test('SHOULD NOT refetch at interval WHEN enabled changes to false', () {
      fakeAsync((async) {
        final start = clock.now();
        var fetchAttempts = 0;
        var enabled = true;

        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              fetchAttempts++;
              await Future.delayed(const Duration(seconds: 3));
              return 'data-$fetchAttempts';
            },
            enabled: enabled,
            refetchInterval: const Duration(seconds: 10),
            client: client,
          ),
        );
        expect(context.value.isLoading, isTrue);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(context.value.isFetched, isTrue);
        expect(fetchAttempts, 1);

        async.elapse(start.add(const Duration(seconds: 10)).difference(clock.now()));
        async.flushMicrotasks();
        expect(context.value.isRefetching, isTrue);
        expect(fetchAttempts, 2);

        enabled = false;
        context.rebuild();

        async.elapse(start.add(const Duration(seconds: 20)).difference(clock.now()));
        async.flushMicrotasks();
        expect(context.value.isRefetching, isFalse);
        expect(fetchAttempts, 2);

        async.elapse(start.add(const Duration(seconds: 30)).difference(clock.now()));
        async.flushMicrotasks();
        expect(context.value.isRefetching, isFalse);
        expect(fetchAttempts, 2);
        context.dispose();
      });
    });

    test('SHOULD refetch at interval WHEN data is fresh', () {
      fakeAsync((async) {
        for (final staleDuration in [
          const StaleDuration(hours: 1),
          StaleDuration.infinity,
          StaleDuration.static,
        ]) {
          final start = clock.now();
          var fetchAttempts = 0;

          final context = SimpleHookContext(
            () => useQuery(
              [staleDuration],
              (ctx) async {
                fetchAttempts++;
                await Future.delayed(const Duration(seconds: 3));
                return 'data-$fetchAttempts';
              },
              refetchInterval: const Duration(seconds: 10),
              staleDuration: staleDuration,
              client: client,
            ),
          );
          expect(context.value.isLoading, isTrue);

          async.elapse(const Duration(seconds: 3));
          async.flushMicrotasks();
          expect(context.value.isFetched, isTrue);
          expect(fetchAttempts, 1);

          async.elapse(start.add(const Duration(seconds: 10)).difference(clock.now()));
          async.flushMicrotasks();
          expect(context.value.isRefetching, isTrue);
          expect(fetchAttempts, 2);

          context.dispose();
          client.clear();
        }
      });
    });
  });

  group('retry', () {
    test('SHOULD retry for N times WHEN retry returns duration N times', () {
      fakeAsync((async) {
        for (final N in [0, 1, 2, 4, 8, 16, 32, 64, 128]) {
          final context = SimpleHookContext(
            () => useQuery(
              ['key', N],
              (ctx) async {
                await Future.delayed(Duration.zero);
                throw Exception();
              },
              retry: (retryCount, error) {
                if (retryCount >= N) return null;
                return const Duration(seconds: 1);
              },
              client: client,
            ),
          );

          async.elapse(Duration.zero);
          async.flushMicrotasks();
          expect(context.value.failureCount, 1);

          for (var i = 0; i < N; i++) {
            final retryNth = i + 1;
            async.elapse(const Duration(seconds: 1));
            async.flushMicrotasks();
            expect(context.value.failureCount, 1 + retryNth);
          }
          context.dispose();
          client.clear();
        }
      });
    });

    test('SHOULD NOT retry WHEN retry returns null', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (_, __) => null,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(hours: 24));
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);
        context.dispose();
      });
    });

    test('SHOULD retry with custom logic WHEN retry callback provided', () {
      fakeAsync((async) {
        var attempts = 0;

        final context = SimpleHookContext(
          () => useQuery<Never, String>(
            const ['key'],
            (ctx) async {
              attempts++;
              await Future.delayed(Duration.zero);
              throw 'error-$attempts';
            },
            retry: (retryCount, error) {
              if (error.contains('error-$attempts') && retryCount < 2) {
                return const Duration(seconds: 1);
              }
              return null;
            },
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 2);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 3);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 3);
        context.dispose();
      });
    });

    test('SHOULD increment failureCount on each retry and reset to 0 on every fetch attempt', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery<Never, Exception>(
            ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 5) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: true,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);
        expect(context.value.failureReason, isA<Exception>());

        for (var i = 0; i < 5; i++) {
          final retryNth = i + 1;
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.failureCount, 1 + retryNth);
          expect(context.value.failureReason, isA<Exception>());
        }

        context.dispose();

        context = SimpleHookContext(
          () => useQuery<Never, Exception>(
            ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 5) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: true,
            client: client,
          ),
        );

        expect(context.value.failureCount, 0);
        expect(context.value.failureReason, null);

        async.elapse(Duration.zero);
        async.flushMicrotasks();

        expect(context.value.failureCount, 1);
        expect(context.value.failureReason, isA<Exception>());
        context.dispose();
      });
    });

    test('SHOULD succeed after failed retries', () {
      fakeAsync((async) {
        var attempts = 0;

        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              attempts++;
              await Future.delayed(Duration.zero);
              if (attempts < 3) {
                throw Exception();
              }
              return 'data';
            },
            retry: (retryCount, error) {
              if (retryCount >= 3) return null;
              return const Duration(seconds: 1);
            },
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 2);
        expect(context.value.failureReason, isA<Exception>());

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.status, QueryStatus.success);
        expect(context.value.data, 'data');
        expect(context.value.failureCount, 0);
        expect(context.value.failureReason, null);
        context.dispose();
      });
    });
  });

  group('retryOnMount', () {
    test('SHOULD retry on mount WHEN retryOnMount is true AND query has error', () {
      fakeAsync((async) {
        var maxRetries = 0;
        var context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= maxRetries) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: true,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.status, QueryStatus.error);
        expect(context.value.failureCount, 1);

        context.dispose();

        maxRetries = 3;
        context = SimpleHookContext(
          () => useQuery(
            ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= maxRetries) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: true,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.status, QueryStatus.error);
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(context.value.failureCount, 4);
        context.dispose();
      });
    });

    test('SHOULD NOT retry on mount WHEN retryOnMount is false AND query has error', () {
      fakeAsync((async) {
        var context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 1) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: false,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.status, QueryStatus.pending);
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.status, QueryStatus.error);
        expect(context.value.failureCount, 2);

        context.dispose();

        context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 1) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: false,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.status, QueryStatus.error);
        expect(context.value.failureCount, 2);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.status, QueryStatus.error);
        expect(context.value.failureCount, 2);
        context.dispose();
      });
    });

    test('SHOULD respect retry count WHEN retryOnMount triggers retry', () {
      fakeAsync((async) {
        var attempts = 0;

        var context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              attempts++;
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 2) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: true,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 2);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 3);

        context.dispose();

        context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              attempts++;
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 2) return null;
              return const Duration(seconds: 1);
            },
            retryOnMount: true,
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 2);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 3);

        expect(attempts, 6);
        context.dispose();
      });
    });
  });

  group('retry delay patterns', () {
    test('SHOULD retry with exponential backoff', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 8) return null;
              final delaySeconds = 1 << retryCount;
              return Duration(seconds: delaySeconds > 30 ? 30 : delaySeconds);
            },
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 2);
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(context.value.failureCount, 3);
        async.elapse(const Duration(seconds: 4));
        async.flushMicrotasks();
        expect(context.value.failureCount, 4);
        async.elapse(const Duration(seconds: 8));
        async.flushMicrotasks();
        expect(context.value.failureCount, 5);
        async.elapse(const Duration(seconds: 16));
        async.flushMicrotasks();
        expect(context.value.failureCount, 6);
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(context.value.failureCount, 7);
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(context.value.failureCount, 8);
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(context.value.failureCount, 9);
        context.dispose();
      });
    });

    test('SHOULD retry with fixed delay', () {
      fakeAsync((async) {
        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              if (retryCount >= 8) return null;
              return const Duration(seconds: 1);
            },
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        for (var i = 0; i < 8; i++) {
          final retryNth = i + 1;
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.failureCount, 1 + retryNth);
        }
        context.dispose();
      });
    });

    test('SHOULD retry with custom delay logic', () {
      fakeAsync((async) {
        final delays = <int>[];

        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              await Future.delayed(Duration.zero);
              throw Exception();
            },
            retry: (retryCount, error) {
              final delay = Duration(seconds: 1 * (retryCount + 1));
              delays.add(delay.inSeconds);
              if (retryCount >= 3) return null;
              return delay;
            },
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(context.value.failureCount, 2);

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(context.value.failureCount, 3);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(context.value.failureCount, 4);

        expect(delays, [1, 2, 3, 4]);
        context.dispose();
      });
    });

    test('SHOULD pass correct args to retry callback', () {
      fakeAsync((async) {
        var attempts = 0;
        final retryCounts = [];
        final errors = [];

        final context = SimpleHookContext(
          () => useQuery(
            const ['key'],
            (ctx) async {
              attempts++;
              await Future.delayed(Duration.zero);
              throw 'error-$attempts';
            },
            retry: (retryCount, error) {
              retryCounts.add(retryCount);
              errors.add(error);
              if (retryCount >= 3) return null;
              return const Duration(seconds: 1);
            },
            client: client,
          ),
        );

        async.elapse(Duration.zero);
        async.flushMicrotasks();
        expect(context.value.failureCount, 1);

        for (var i = 0; i < 3; i++) {
          final retryNth = i + 1;
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.failureCount, 1 + retryNth);
        }

        expect(attempts, 4);
        expect(retryCounts, [0, 1, 2, 3]);
        expect(errors, ['error-1', 'error-2', 'error-3', 'error-4']);
        context.dispose();
      });
    });
  });

  group('refetch', () {
    test(
        'SHOULD refetch'
        'WHEN refetch is called', () async {
      var fetches = 0;
      final completers = <Completer<String>>[];

      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async {
            fetches++;
            final c = Completer<String>();
            completers.add(c);
            return c.future;
          },
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(fetches, 1);

      completers[0].complete('data-1');
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-1');

      context.value.refetch();
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(fetches, 2);

      completers[1].complete('data-2');
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-2');
      context.dispose();
    });

    test(
        'SHOULD cancel in-progress fetch AND refetch again '
        'WHEN cancelRefetch == true', () async {
      var fetches = 0;
      final completers = <Completer<String>>[];

      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async {
            fetches++;
            final c = Completer<String>();
            completers.add(c);
            return c.future;
          },
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      completers[0].complete('data-1');
      await asyncYield();
      expect(context.value.data, 'data-1');
      expect(fetches, 1);

      context.value.refetch();
      await asyncYield();
      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(fetches, 2);

      // cancelRefetch: true cancels the in-progress fetch (fetch #2) and starts fetch #3
      context.value.refetch(cancelRefetch: true);
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(context.value.data, 'data-1');
      expect(fetches, 3);

      completers[2].complete('data-3');
      await asyncYield();

      expect(context.value.fetchStatus, FetchStatus.idle);
      expect(context.value.data, 'data-3');
      context.dispose();
    });

    test(
        'SHOULD return in-progress fetch result '
        'WHEN cancelRefetch == false', () async {
      var fetches = 0;
      final completers = <Completer<String>>[];

      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async {
            fetches++;
            final c = Completer<String>();
            completers.add(c);
            return c.future;
          },
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      completers[0].complete('data-1');
      await asyncYield();
      expect(context.value.data, 'data-1');
      expect(fetches, 1);

      context.value.refetch();
      await asyncYield();
      expect(context.value.fetchStatus, FetchStatus.fetching);
      expect(fetches, 2);

      // cancelRefetch: false — reuses in-progress fetch #2, no new fetch started
      context.value.refetch(cancelRefetch: false);
      await asyncYield();

      expect(fetches, 2);

      completers[1].complete('data-2');
      await asyncYield();

      expect(context.value.data, 'data-2');
      expect(fetches, 2);
      context.dispose();
    });

    test(
        'SHOULD swallow errors '
        'WHEN throwOnError == false', () async {
      var fetches = 0;
      final completers = <Completer<String>>[];

      final context = SimpleHookContext(
        () => useQuery<String, Object>(
          const ['key'],
          (ctx) async {
            fetches++;
            final c = Completer<String>();
            completers.add(c);
            return c.future;
          },
          retry: (_, __) => null,
          client: client,
        ),
      );

      completers[0].completeError(Exception());
      await asyncYield();
      expect(context.value.status, QueryStatus.error);
      expect(context.value.error, isA<Exception>());
      expect(fetches, 1);

      Object? caughtError;
      context.value.refetch(throwOnError: false).then((_) {}, onError: (e) {
        caughtError = e;
      });
      await asyncYield();

      completers[1].completeError(Exception());
      await asyncYield();

      expect(caughtError, isNull);
      expect(fetches, 2);
      context.dispose();
    });

    test(
        'SHOULD propagate errors '
        'WHEN throwOnError == true', () async {
      var fetches = 0;
      final thrownError = Exception();
      final completers = <Completer<String>>[];

      final context = SimpleHookContext(
        () => useQuery<String, Object>(
          const ['key'],
          (ctx) async {
            fetches++;
            final c = Completer<String>();
            completers.add(c);
            return c.future;
          },
          retry: (_, __) => null,
          client: client,
        ),
      );

      completers[0].completeError(thrownError);
      await asyncYield();
      expect(context.value.status, QueryStatus.error);
      expect(context.value.error, same(thrownError));
      expect(fetches, 1);

      Object? caughtError;
      context.value.refetch(throwOnError: true).then((_) {}, onError: (e) {
        caughtError = e;
      });
      await asyncYield();

      completers[1].completeError(thrownError);
      await asyncYield();

      expect(caughtError, same(thrownError));
      expect(fetches, 2);
      context.dispose();
    });

    test(
        'SHOULD return updated QueryResult'
        '', () async {
      final completers = <Completer<String>>[];

      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async {
            final c = Completer<String>();
            completers.add(c);
            return c.future;
          },
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      completers[0].complete('data-1');
      await asyncYield();
      expect(context.value.data, 'data-1');

      late QueryResult result;
      context.value.refetch().then((r) => result = r);
      await asyncYield();

      completers[1].complete('data-2');
      await asyncYield();

      expect(result.data, 'data-2');
      context.dispose();
    });
  });

  group('isFetchedAfterMount', () {
    test('SHOULD be false initially and true after successful fetch', () async {
      final completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => completer.future,
          client: client,
        ),
      );

      expect(context.value.isFetchedAfterMount, false);

      completer.complete('data');
      await asyncYield();

      expect(context.value.isFetchedAfterMount, true);
      context.dispose();
    });

    test('SHOULD be true after failed fetch', () async {
      final completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery<String, Object>(
          const ['key'],
          (ctx) async => completer.future,
          retry: (_, __) => null,
          client: client,
        ),
      );

      expect(context.value.isFetchedAfterMount, false);

      completer.completeError(Exception('error'));
      await asyncYield();

      expect(context.value.status, QueryStatus.error);
      expect(context.value.isFetchedAfterMount, true);
      context.dispose();
    });

    test('SHOULD be false when using cached data from before mount', () async {
      var completer = Completer<String>();
      final context1 = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => completer.future,
          client: client,
        ),
      );

      completer.complete('cached-data');
      await asyncYield();
      expect(context1.value.data, 'cached-data');
      expect(context1.value.isFetchedAfterMount, true);

      context1.dispose();

      completer = Completer<String>();
      final context2 = SimpleHookContext(
        () => useQuery(
          const ['key'],
          (ctx) async => completer.future,
          staleDuration: StaleDuration.infinity,
          client: client,
        ),
      );

      expect(context2.value.data, 'cached-data');
      expect(context2.value.isFetchedAfterMount, false);
      context2.dispose();
    });

    test('SHOULD reset to false when query key changes', () async {
      var key = const <Object?>['key-1'];
      var completer = Completer<String>();
      final context = SimpleHookContext(
        () => useQuery(
          key,
          (ctx) async => completer.future,
          client: client,
        ),
      );

      completer.complete('data-${key.first}');
      await asyncYield();
      expect(context.value.isFetchedAfterMount, true);

      key = const ['key-2'];
      completer = Completer<String>();
      context.rebuild();

      expect(context.value.isFetchedAfterMount, false);

      completer.complete('data-${key.first}');
      await asyncYield();

      expect(context.value.isFetchedAfterMount, true);
      context.dispose();
    });
  });

  group('meta', () {
    test('SHOULD pass meta to query function via context', () async {
      final meta = {'feature': 'user-list', 'experiment': 'v2'};
      Map<String, dynamic>? capturedMeta;

      final context = SimpleHookContext(
        () => useQuery(
          const ['users'],
          (ctx) async {
            capturedMeta = ctx.meta;
            return 'data';
          },
          meta: meta,
          client: client,
        ),
      );

      await asyncYield();

      expect(capturedMeta, meta);
      expect(capturedMeta!['feature'], 'user-list');
      expect(capturedMeta!['experiment'], 'v2');
      context.dispose();
    });

    test('SHOULD pass empty meta WHEN not provided', () async {
      Map<String, dynamic>? capturedMeta;
      var wasCalled = false;

      final context = SimpleHookContext(
        () => useQuery(
          const ['users'],
          (ctx) async {
            wasCalled = true;
            capturedMeta = ctx.meta;
            return 'data';
          },
          client: client,
        ),
      );

      await asyncYield();

      expect(wasCalled, isTrue);
      expect(capturedMeta, isEmpty);
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
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'data';
              },
              networkMode: NetworkMode.online,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data, 'data');
          context.dispose();
        });
      });

      test(
          'SHOULD pause offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          connectivityController.add(false);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'data';
              },
              networkMode: NetworkMode.online,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.paused);
          expect(context.value.isPaused, isTrue);

          async.elapse(const Duration(days: 365));
          async.flushMicrotasks();
          expect(context.value.fetchStatus, FetchStatus.paused);
          expect(context.value.isPaused, isTrue);

          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data, 'data');
          context.dispose();
        });
      });

      test(
          'SHOULD pause retries on going offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          connectivityController.add(true);
          async.flushMicrotasks();

          var queryFnCount = 0;
          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                queryFnCount++;
                throw Exception();
              },
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

          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(queryFnCount, 1);

          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
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

    group('== NetworkMode.always', () {
      // Never pauses, ignores network state

      test(
          'SHOULD fetch normally online'
          '', () {
        fakeAsync((async) {
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'data';
              },
              networkMode: NetworkMode.always,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data, 'data');
          context.dispose();
        });
      });

      test(
          'SHOULD fetch normally offline'
          '', () {
        fakeAsync((async) {
          connectivityController.add(false);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'data';
              },
              networkMode: NetworkMode.always,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data, 'data');
          context.dispose();
        });
      });

      test(
          'SHOULD NOT pause on going offline'
          '', () {
        fakeAsync((async) {
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'data';
              },
              networkMode: NetworkMode.always,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data, 'data');
          context.dispose();
        });
      });

      test(
          'SHOULD NOT pause retries on going offline'
          '', () {
        fakeAsync((async) {
          connectivityController.add(true);
          async.flushMicrotasks();

          var queryFnCount = 0;
          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                queryFnCount++;
                throw Exception();
              },
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

          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(queryFnCount, 1);

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
          connectivityController.add(true);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'data';
              },
              networkMode: NetworkMode.offlineFirst,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data, 'data');
          context.dispose();
        });
      });

      test(
          'SHOULD execute initial fetch normally offline'
          '', () {
        fakeAsync((async) {
          connectivityController.add(false);
          async.flushMicrotasks();

          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                await Future.delayed(const Duration(seconds: 1));
                return 'data';
              },
              networkMode: NetworkMode.offlineFirst,
              client: client,
            ),
          );

          expect(context.value.fetchStatus, FetchStatus.fetching);
          expect(context.value.isPaused, isFalse);

          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(context.value.status, QueryStatus.success);
          expect(context.value.data, 'data');
          context.dispose();
        });
      });

      test(
          'SHOULD pause retries offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          connectivityController.add(false);
          async.flushMicrotasks();

          var queryFnCount = 0;
          final context = SimpleHookContext(
            () => useQuery<String, Object>(
              const ['key'],
              (_) async {
                queryFnCount++;
                throw Exception();
              },
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
          expect(queryFnCount, 1);

          async.elapse(const Duration(days: 365));
          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(queryFnCount, 1);

          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
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
  });

  group('Shared key', () {
    // Regression test for https://github.com/jezsung/query/issues/40
    test(
        'SHOULD NOT throw markNeedsBuild error '
        'WHEN navigating to screen that shares the same query key', () async {
      final completer = Completer<String>();
      final contextA = SimpleHookContext(
        () => useQuery(
          ['branch', 'id-1'],
          (context) async => completer.future,
          client: client,
        ),
      );

      completer.complete('data-a');
      await asyncYield();

      expect(contextA.value.status, QueryStatus.success);
      expect(contextA.value.data, 'data-a');

      // "Navigate" — add second observer sharing same key
      final contextB = SimpleHookContext(
        () => useQuery(
          ['branch', 'id-1'],
          (context) async => 'data-b',
          client: client,
        ),
      );

      await asyncYield();

      expect(contextA.value.status, QueryStatus.success);
      expect(contextB.value.status, QueryStatus.success);
      contextA.dispose();
      contextB.dispose();
    });
  });
}
