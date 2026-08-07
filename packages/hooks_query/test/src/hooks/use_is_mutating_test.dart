import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

import 'package:utopia_hooks_query/src/core/core.dart';
import 'package:utopia_hooks_query/src/hooks/hooks.dart';

void main() {
  late QueryClient client;

  setUp(() {
    client = QueryClient();
  });

  tearDown(() {
    client.clear();
  });

  test(
      'SHOULD return 0 '
      'WHEN no mutations are pending', () async {
    final context = SimpleHookContext(
      () => useIsMutating(client: client),
    );

    expect(context.value, 0);
    context.dispose();
  });

  test(
      'SHOULD return 1 '
      'WHEN one mutation is pending', () async {
    final completer = Completer<String>();
    final context = SimpleHookContext(() {
      final mutation = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        client: client,
      );
      return (
        mutate: mutation.mutate,
        count: useIsMutating(client: client),
      );
    });

    expect(context.value.count, 0);

    context.value.mutate('test');

    expect(context.value.count, 1);
    context.dispose();
  });

  test(
      'SHOULD return correct count '
      'WHEN multiple mutations are pending', () {
    fakeAsync((async) {
      final context = SimpleHookContext(() {
        final mutation1 = useMutation<String, dynamic, String, dynamic>(
          (variables, context) async {
            await Future.delayed(const Duration(seconds: 2));
            return 'data-1';
          },
          client: client,
        );
        final mutation2 = useMutation<String, dynamic, String, dynamic>(
          (variables, context) async {
            await Future.delayed(const Duration(seconds: 1));
            return 'data-2';
          },
          client: client,
        );
        return (
          mutate1: mutation1.mutate,
          mutate2: mutation2.mutate,
          count: useIsMutating(client: client),
        );
      });

      expect(context.value.count, 0);

      context.value.mutate1('test-1');
      context.value.mutate2('test-2');

      expect(context.value.count, 2);

      // Second mutation completes after 1 second
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(context.value.count, 1);
      // First mutation completes after another 1 second
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(context.value.count, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD return new count '
      'WHEN mutationKey changes', () {
    fakeAsync((async) {
      var mutationKey = const <Object?>['users'];
      final context = SimpleHookContext(
        () {
          final mutation1 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            mutationKey: const ['users', 1],
            client: client,
          );
          final mutation2 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            mutationKey: const ['users', 2],
            client: client,
          );
          final mutation3 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data';
            },
            mutationKey: const ['posts', 1],
            client: client,
          );
          return (
            mutate1: mutation1.mutate,
            mutate2: mutation2.mutate,
            mutate3: mutation3.mutate,
            count: useIsMutating(mutationKey: mutationKey, client: client),
          );
        },
        shouldRebuild: false,
      );

      context.value.mutate1('test1');
      context.value.mutate2('test2');
      context.value.mutate3('test3');
      context.rebuild();
      expect(context.value.count, 2);

      mutationKey = const ['posts'];
      context.rebuild();
      expect(context.value.count, 1);

      // 'posts' mutation completes
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value.count, 0);
      // 'users' mutations complete, should not affect count
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value.count, 0);
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
          final mutation1 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data';
            },
            mutationKey: const ['users'],
            client: client,
          );
          final mutation2 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            mutationKey: const ['users', 1],
            client: client,
          );
          final mutation3 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            mutationKey: const ['users', 2],
            client: client,
          );
          return (
            mutate1: mutation1.mutate,
            mutate2: mutation2.mutate,
            mutate3: mutation3.mutate,
            count: useIsMutating(
              mutationKey: const ['users'],
              exact: exact,
              client: client,
            ),
          );
        },
        shouldRebuild: false,
      );

      context.value.mutate1('test1');
      context.value.mutate2('test2');
      context.value.mutate3('test3');
      context.rebuild();
      expect(context.value.count, 3);

      exact = true;
      context.rebuild();
      expect(context.value.count, 1);

      // ['users'] mutation completes
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value.count, 0);
      // Other mutations complete, should not affect count
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value.count, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD return new count '
      'WHEN predicate changes', () {
    fakeAsync((async) {
      var predicate = (List<Object?>? key, MutationState state) =>
          key != null && key.length > 1 && key[1] == 1;
      final context = SimpleHookContext(
        () {
          final mutation1 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 1));
              return 'data';
            },
            mutationKey: const ['users', 1],
            client: client,
          );
          final mutation2 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            mutationKey: const ['users', 2],
            client: client,
          );
          final mutation3 = useMutation<String, dynamic, String, dynamic>(
            (variables, context) async {
              await Future.delayed(const Duration(seconds: 2));
              return 'data';
            },
            mutationKey: const ['users', 3],
            client: client,
          );
          return (
            mutate1: mutation1.mutate,
            mutate2: mutation2.mutate,
            mutate3: mutation3.mutate,
            count: useIsMutating(predicate: predicate, client: client),
          );
        },
        shouldRebuild: false,
      );

      context.value.mutate1('test1');
      context.value.mutate2('test2');
      context.value.mutate3('test3');
      context.rebuild();
      // Predicate matches only ['users', 1]
      expect(context.value.count, 1);

      predicate = (key, state) => key != null && key.length > 1 && key[1] != 1;
      context.rebuild();
      // New predicate matches ['users', 2] and ['users', 3]
      expect(context.value.count, 2);

      // ['users', 1] mutation completes, should not affect count
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value.count, 2);

      // ['users', 2] and ['users', 3] complete
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      context.rebuild();
      expect(context.value.count, 0);
      context.dispose();
    });
  });

  test(
      'SHOULD filter by key prefix '
      'WHEN exact == false', () async {
    final completer = Completer<String>();
    final context = SimpleHookContext(() {
      final mutation1 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users'],
        client: client,
      );
      final mutation2 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 1],
        client: client,
      );
      final mutation3 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 2],
        client: client,
      );
      final mutation4 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['posts', 1],
        client: client,
      );
      return (
        mutate1: mutation1.mutate,
        mutate2: mutation2.mutate,
        mutate3: mutation3.mutate,
        mutate4: mutation4.mutate,
        users: useIsMutating(
          mutationKey: const ['users'],
          exact: false,
          client: client,
        ),
        posts: useIsMutating(
          mutationKey: const ['posts'],
          exact: false,
          client: client,
        ),
        comments: useIsMutating(
          mutationKey: const ['comments'],
          exact: false,
          client: client,
        ),
      );
    });

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');
    context.value.mutate4('test4');

    expect(context.value.users, 3);
    expect(context.value.posts, 1);
    expect(context.value.comments, 0);
    context.dispose();
  });

  test(
      'SHOULD filter by exact key '
      'WHEN exact == true', () async {
    final completer = Completer<String>();
    final context = SimpleHookContext(() {
      final mutation1 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users'],
        client: client,
      );
      final mutation2 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 1],
        client: client,
      );
      final mutation3 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 2],
        client: client,
      );
      return (
        mutate1: mutation1.mutate,
        mutate2: mutation2.mutate,
        mutate3: mutation3.mutate,
        count: useIsMutating(
          mutationKey: const ['users'],
          exact: true,
          client: client,
        ),
      );
    });

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');

    expect(context.value.count, 1);
    context.dispose();
  });

  test(
      'SHOULD filter by predicate'
      '', () async {
    final completer = Completer<String>();
    final context = SimpleHookContext(() {
      final mutation1 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users'],
        client: client,
      );
      final mutation2 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 1],
        client: client,
      );
      final mutation3 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 2],
        client: client,
      );
      return (
        mutate1: mutation1.mutate,
        mutate2: mutation2.mutate,
        mutate3: mutation3.mutate,
        count: useIsMutating(
          predicate: (key, state) =>
              key != null && key.length > 1 && key[1] == 1,
          client: client,
        ),
      );
    });

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');

    expect(context.value.count, 1);
    context.dispose();
  });

  test(
      'SHOULD filter by key and predicate'
      '', () async {
    final completer = Completer<String>();
    final context = SimpleHookContext(() {
      final mutation1 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 1],
        client: client,
      );
      final mutation2 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['users', 2],
        client: client,
      );
      final mutation3 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async => completer.future,
        mutationKey: const ['posts', 1],
        client: client,
      );
      return (
        mutate1: mutation1.mutate,
        mutate2: mutation2.mutate,
        mutate3: mutation3.mutate,
        count: useIsMutating(
          mutationKey: const ['users'],
          predicate: (key, state) =>
              key != null && key.length > 1 && key[1] == 1,
          client: client,
        ),
      );
    });

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');

    expect(context.value.count, 1);
    context.dispose();
  });
}
