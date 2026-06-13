import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

import 'package:utopia_hooks_query/src/core/core.dart';
import 'package:utopia_hooks_query/src/hooks/hooks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QueryClient client;

  setUp(() {
    client = QueryClient();
  });

  tearDown(() {
    client.clear();
  });

  test(
      'SHOULD return 0 '
      'WHEN no queries are fetching', () async {
    final context = SimpleHookContext(
      () => useIsFetching(client: client),
    );

    expect(context.value, 0);
    context.dispose();
  });

  test(
      'SHOULD return 1 '
      'WHEN one query is fetching', () async {
    final context = SimpleHookContext(() {
      useQuery(
        const ['key'],
        (context) => Completer().future,
        client: client,
      );
      return useIsFetching(client: client);
    });

    expect(context.value, 1);
    context.dispose();
  });

  test(
      'SHOULD return correct count '
      'WHEN multiple queries are fetching', () {
    fakeAsync((async) {
      final context = SimpleHookContext(() {
        useQuery(
          const ['first'],
          (context) async {
            await Future.delayed(const Duration(seconds: 3));
            return 'data';
          },
          client: client,
        );
        useQuery(
          const ['second'],
          (context) async {
            await Future.delayed(const Duration(seconds: 2));
            return 'data';
          },
          client: client,
        );
        return useIsFetching(client: client);
      });

      expect(context.value, 2);

      client.fetchQuery(
        const ['third'],
        (context) async {
          await Future.delayed(const Duration(seconds: 1));
          return 'data';
        },
      ).ignore();
      async.flushMicrotasks();
      expect(context.value, 3);

      // 'third' query completes
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(context.value, 2);
      // 'second' query completes
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(context.value, 1);
      // 'first' query completes
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(context.value, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD NOT count queries that are not fetching'
      '', () {
    fakeAsync((async) {
      final context = SimpleHookContext(() {
        useQuery(
          const ['key'],
          (context) => Completer().future,
          enabled: false,
          client: client,
        );
        return useIsFetching(client: client);
      });

      expect(context.value, 0);

      async.elapse(const Duration(hours: 365));
      async.flushMicrotasks();

      expect(context.value, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD return new count '
      'WHEN queryKey changes', () {
    fakeAsync((async) {
      var queryKey = const <Object?>['users'];
      final context = SimpleHookContext(
        () {
          useQuery(
            const ['users', 1],
            (context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            client: client,
          );
          useQuery(
            const ['users', 2],
            (context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            client: client,
          );
          useQuery(
            const ['posts', 1],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data';
            },
            client: client,
          );
          return useIsFetching(queryKey: queryKey, client: client);
        },
        shouldRebuild: false,
      );
      context.rebuild();
      expect(context.value, 2);

      queryKey = const ['posts'];
      context.rebuild();
      expect(context.value, 1);

      // 'posts' query completes
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value, 0);

      // 'users' queries complete, should not affect count
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD return new count '
      'WHEN exact changes', () {
    fakeAsync((async) {
      var exact = false;
      final context = SimpleHookContext(
        () {
          useQuery(
            const ['users'],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data';
            },
            client: client,
          );
          useQuery(
            const ['users', 1],
            (context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            client: client,
          );
          useQuery(
            const ['users', 2],
            (context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            client: client,
          );
          return useIsFetching(
            queryKey: const ['users'],
            exact: exact,
            client: client,
          );
        },
        shouldRebuild: false,
      );
      context.rebuild();
      // exact: false matches all 3 queries
      expect(context.value, 3);

      exact = true;
      context.rebuild();
      // exact: true matches only ['users']
      expect(context.value, 1);

      // ['users'] query completes
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value, 0);

      // Other queries complete, should not affect count
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD return new count '
      'WHEN predicate changes', () {
    fakeAsync((async) {
      var predicate = (List<Object?> key, QueryState state) =>
          key.length > 1 && key[1] == 1;
      final context = SimpleHookContext(
        () {
          useQuery(
            const ['users', 1],
            (context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data';
            },
            client: client,
          );
          useQuery(
            const ['users', 2],
            (context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            client: client,
          );
          useQuery(
            const ['users', 3],
            (context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            client: client,
          );
          return useIsFetching(predicate: predicate, client: client);
        },
        shouldRebuild: false,
      );
      context.rebuild();
      // Predicate matches only ['users', 1]
      expect(context.value, 1);

      predicate = (key, state) => key.length > 1 && key[1] != 1;
      context.rebuild();
      // New predicate matches ['users', 2] and ['users', 3]
      expect(context.value, 2);

      // ['users', 1] query completes, should not affect count
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value, 2);

      // ['users', 2] and ['users', 3] complete
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD filter by key prefix '
      'WHEN exact == false', () async {
    final context = SimpleHookContext(() {
      useQuery(
        const ['users'],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['users', 1],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['users', 2],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['posts', 1],
        (context) => Completer().future,
        client: client,
      );
      return (
        users: useIsFetching(
          queryKey: const ['users'],
          exact: false,
          client: client,
        ),
        posts: useIsFetching(
          queryKey: const ['posts'],
          exact: false,
          client: client,
        ),
        comments: useIsFetching(
          queryKey: const ['comments'],
          exact: false,
          client: client,
        ),
      );
    });

    expect(context.value.users, 3);
    expect(context.value.posts, 1);
    expect(context.value.comments, 0);
    context.dispose();
  });

  test(
      'SHOULD filter by exact key '
      'WHEN exact == true', () async {
    final context = SimpleHookContext(() {
      useQuery(
        const ['users'],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['users', 1],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['users', 2],
        (context) => Completer().future,
        client: client,
      );
      return useIsFetching(
        queryKey: const ['users'],
        exact: true,
        client: client,
      );
    });

    expect(context.value, 1);
    context.dispose();
  });

  test(
      'SHOULD filter by predicate'
      '', () async {
    final context = SimpleHookContext(() {
      useQuery(
        const ['users'],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['users', 1],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['users', 2],
        (context) => Completer().future,
        client: client,
      );
      return useIsFetching(
        predicate: (key, state) => key.length > 1 && key[1] == 1,
        client: client,
      );
    });

    expect(context.value, 1);
    context.dispose();
  });

  test(
      'SHOULD filter by key and predicate'
      '', () async {
    final context = SimpleHookContext(() {
      useQuery(
        const ['users', 1],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['users', 2],
        (context) => Completer().future,
        client: client,
      );
      useQuery(
        const ['posts', 1],
        (context) => Completer().future,
        client: client,
      );
      return useIsFetching(
        queryKey: const ['users'],
        predicate: (key, state) => key.length > 1 && key[1] == 1,
        client: client,
      );
    });

    expect(context.value, 1);
    context.dispose();
  });
}
