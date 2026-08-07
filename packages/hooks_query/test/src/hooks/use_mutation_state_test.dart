import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

import 'package:utopia_hooks_query/src/core/core.dart';
import 'package:utopia_hooks_query/src/hooks/hooks.dart';
import '../../utils.dart';

void main() {
  late QueryClient client;

  setUp(() {
    client = QueryClient();
  });

  tearDown(() {
    client.clear();
  });

  test(
      'SHOULD return empty list '
      'WHEN no mutations exist', () async {
    final context = SimpleHookContext(
      () => useMutationState(client: client),
    );

    expect(context.value, isEmpty);
    context.dispose();
  });

  test(
      'SHOULD return mutation states '
      'WHEN mutations exist', () async {
    final context = SimpleHookContext(() {
      final mutation = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async {
          await Future.delayed(const Duration(seconds: 1));
          return 'data';
        },
        client: client,
      );
      return (
        mutate: mutation.mutate,
        states: useMutationState(client: client),
      );
    });

    expect(context.value.states, isEmpty);

    context.value.mutate('test');

    expect(context.value.states, hasLength(1));
    expect(context.value.states.first.status, MutationStatus.pending);
    expect(context.value.states.first.variables, 'test');
    context.dispose();
  });

  test(
      'SHOULD return multiple mutation states '
      'WHEN multiple mutations exist', () async {
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
        states: useMutationState(client: client),
      );
    });

    expect(context.value.states, isEmpty);

    context.value.mutate1('test-1');
    context.value.mutate2('test-2');

    expect(context.value.states, hasLength(2));
    context.dispose();
  });

  test(
      'SHOULD update states '
      'WHEN mutation status changes', () async {
    final completer = Completer<String>();
    final context = SimpleHookContext(() {
      final mutation = useMutation<String, dynamic, String, dynamic>(
        (variables, ctx) async => completer.future,
        client: client,
      );
      return (
        mutate: mutation.mutate,
        states: useMutationState(client: client),
      );
    });

    context.value.mutate('test');

    expect(context.value.states.first.status, MutationStatus.pending);

    completer.complete('data');
    await asyncYield();

    expect(context.value.states.first.status, MutationStatus.success);
    expect(context.value.states.first.data, 'data');
    context.dispose();
  });

  test(
      'SHOULD filter by key prefix '
      'WHEN mutationKey provided and exact == false', () async {
    final context = SimpleHookContext(() {
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
          await Future.delayed(const Duration(seconds: 1));
          return 'data';
        },
        mutationKey: const ['users', 1],
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
        userStates: useMutationState(
          mutationKey: const ['users'],
          exact: false,
          client: client,
        ),
        postStates: useMutationState(
          mutationKey: const ['posts'],
          exact: false,
          client: client,
        ),
      );
    });

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');

    expect(context.value.userStates, hasLength(2));
    expect(context.value.postStates, hasLength(1));
    context.dispose();
  });

  test(
      'SHOULD filter by exact key '
      'WHEN exact == true', () async {
    final context = SimpleHookContext(() {
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
          await Future.delayed(const Duration(seconds: 1));
          return 'data';
        },
        mutationKey: const ['users', 1],
        client: client,
      );
      final mutation3 = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async {
          await Future.delayed(const Duration(seconds: 1));
          return 'data';
        },
        mutationKey: const ['users', 2],
        client: client,
      );
      return (
        mutate1: mutation1.mutate,
        mutate2: mutation2.mutate,
        mutate3: mutation3.mutate,
        states: useMutationState(
          mutationKey: const ['users'],
          exact: true,
          client: client,
        ),
      );
    });

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');

    expect(context.value.states, hasLength(1));
    expect(context.value.states.first.variables, 'test1');
    context.dispose();
  });

  test(
      'SHOULD filter by predicate'
      '', () async {
    final context = SimpleHookContext(() {
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
          await Future.delayed(const Duration(seconds: 1));
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
        mutationKey: const ['users', 3],
        client: client,
      );
      return (
        mutate1: mutation1.mutate,
        mutate2: mutation2.mutate,
        mutate3: mutation3.mutate,
        states: useMutationState(
          predicate: (key, state) =>
              key != null && key.length > 1 && key[1] == 1,
          client: client,
        ),
      );
    });

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');

    expect(context.value.states, hasLength(1));
    expect(context.value.states.first.variables, 'test1');
    context.dispose();
  });

  test(
      'SHOULD filter by status via predicate'
      '', () async {
    final completer1 = Completer<String>();
    final completer2 = Completer<String>();
    final context = SimpleHookContext(() {
      final mutation1 = useMutation<String, dynamic, String, dynamic>(
        (variables, ctx) async => completer1.future,
        client: client,
      );
      final mutation2 = useMutation<String, dynamic, String, dynamic>(
        (variables, ctx) async => completer2.future,
        client: client,
      );
      return (
        mutate1: mutation1.mutate,
        mutate2: mutation2.mutate,
        pendingStates: useMutationState(
          predicate: (key, state) => state.status == MutationStatus.pending,
          client: client,
        ),
        successStates: useMutationState(
          predicate: (key, state) => state.status == MutationStatus.success,
          client: client,
        ),
      );
    });

    context.value.mutate1('test-1');
    context.value.mutate2('test-2');

    expect(context.value.pendingStates, hasLength(2));
    expect(context.value.successStates, isEmpty);

    // Second mutation completes first
    completer2.complete('data-2');
    await asyncYield();

    expect(context.value.pendingStates, hasLength(1));
    expect(context.value.successStates, hasLength(1));

    // First mutation completes
    completer1.complete('data-1');
    await asyncYield();

    expect(context.value.pendingStates, isEmpty);
    expect(context.value.successStates, hasLength(2));
    context.dispose();
  });

  test(
      'SHOULD filter by key and predicate'
      '', () async {
    final context = SimpleHookContext(() {
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
          await Future.delayed(const Duration(seconds: 1));
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
        states: useMutationState(
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

    expect(context.value.states, hasLength(1));
    expect(context.value.states.first.variables, 'test1');
    context.dispose();
  });

  test(
      'SHOULD return new states '
      'WHEN mutationKey changes', () async {
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
          states: useMutationState(mutationKey: mutationKey, client: client),
        );
      },
      shouldRebuild: false,
    );

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');
    context.rebuild();
    expect(context.value.states, hasLength(2));

    mutationKey = const ['posts'];
    context.rebuild();
    expect(context.value.states, hasLength(1));
    context.dispose();
  });

  test(
      'SHOULD return new states '
      'WHEN exact changes', () async {
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
          states: useMutationState(
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
    expect(context.value.states, hasLength(3));

    exact = true;
    context.rebuild();
    expect(context.value.states, hasLength(1));
    context.dispose();
  });

  test(
      'SHOULD return new states '
      'WHEN predicate changes', () async {
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
          states: useMutationState(predicate: predicate, client: client),
        );
      },
      shouldRebuild: false,
    );

    context.value.mutate1('test1');
    context.value.mutate2('test2');
    context.value.mutate3('test3');
    context.rebuild();
    // Predicate matches only ['users', 1]
    expect(context.value.states, hasLength(1));

    predicate = (key, state) => key != null && key.length > 1 && key[1] != 1;
    context.rebuild();
    // New predicate matches ['users', 2] and ['users', 3]
    expect(context.value.states, hasLength(2));
    context.dispose();
  });

  test(
      'SHOULD update when mutation is added'
      '', () async {
    final context = SimpleHookContext(() {
      final mutation = useMutation<String, dynamic, String, dynamic>(
        (variables, context) async {
          await Future.delayed(const Duration(seconds: 1));
          return 'data';
        },
        client: client,
      );
      return (
        mutate: mutation.mutate,
        states: useMutationState(client: client),
      );
    });

    expect(context.value.states, isEmpty);

    context.value.mutate('first');
    expect(context.value.states, hasLength(1));

    context.value.mutate('second');
    expect(context.value.states, hasLength(2));
    context.dispose();
  });

  test(
      'SHOULD update when mutation is removed'
      '', () {
    fakeAsync((async) {
      late MutationResult<String, dynamic, String, dynamic> mutationResult;
      final contextMutation = SimpleHookContext(() {
        mutationResult = useMutation<String, dynamic, String, dynamic>(
          (variables, context) async {
            await Future.delayed(const Duration(seconds: 1));
            return 'data';
          },
          gcDuration: const GcDuration(minutes: 3),
          client: client,
        );
        return mutationResult;
      });

      final contextStates = SimpleHookContext(
        () => useMutationState(client: client),
      );

      expect(contextStates.value, isEmpty);

      contextMutation.value.mutate('test');
      contextStates.rebuild();
      expect(contextStates.value, hasLength(1));

      // Mutation completes after 1 second
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(contextStates.value, hasLength(1));

      // Dispose mutation context — no more observers on that mutation
      contextMutation.dispose();

      // Mutation is garbage collected after another 3 minutes
      async.elapse(const Duration(minutes: 3));
      async.flushMicrotasks();
      expect(contextStates.value, isEmpty);

      contextStates.dispose();
    });
  });
}
