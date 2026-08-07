import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

import 'package:utopia_hooks_query/src/core/core.dart';
import 'package:utopia_hooks_query/src/hooks/hooks.dart';
import '../../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QueryClient client;

  setUp(() {
    client = QueryClient();
  });

  tearDown(() {
    client.clear();
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
          'SHOULD execute normally online'
          '', () async {
        // Start online
        connectivityController.add(true);
        await asyncYield();

        final completer = Completer<String>();
        final context = SimpleHookContext(
          () => useMutation<String, Object, void, void>(
            (_, __) async => completer.future,
            networkMode: NetworkMode.online,
            client: client,
          ),
        );

        context.value.mutate(null);
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        completer.complete('data');
        await asyncYield();
        expect(context.value.status, MutationStatus.success);
        expect(context.value.data, 'data');
        context.dispose();
      });

      test(
          'SHOULD pause offline, then resume on going online'
          '', () async {
        // Start offline
        connectivityController.add(false);
        await asyncYield();

        final completer = Completer<String>();
        final context = SimpleHookContext(
          () => useMutation<String, Object, void, void>(
            (_, __) async => completer.future,
            networkMode: NetworkMode.online,
            client: client,
          ),
        );

        context.value.mutate(null);
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isTrue);

        // Should be kept paused
        await asyncYield();
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isTrue);

        // Go online
        connectivityController.add(true);
        await asyncYield();
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        completer.complete('data');
        await asyncYield();
        expect(context.value.status, MutationStatus.success);
        expect(context.value.data, 'data');
        context.dispose();
      });

      test(
          'SHOULD pause retries on going offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          var mutateFnCount = 0;
          final context = SimpleHookContext(
            () => useMutation<String, Object, void, void>(
              (_, __) async {
                mutateFnCount++;
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

          context.value.mutate(null);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(mutateFnCount, 1);

          // Go offline
          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(mutateFnCount, 1);

          // Go online
          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(mutateFnCount, 2);

          // Wait for remaining retries to complete
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(mutateFnCount, 3);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(mutateFnCount, 4);
          expect(context.value.status, MutationStatus.error);
          context.dispose();
        });
      });
    });

    group('== NetworkMode.always', () {
      // Never pauses, ignores network state

      test(
          'SHOULD execute normally online'
          '', () async {
        // Start online
        connectivityController.add(true);
        await asyncYield();

        final completer = Completer<String>();
        final context = SimpleHookContext(
          () => useMutation<String, Object, void, void>(
            (_, __) async => completer.future,
            networkMode: NetworkMode.always,
            client: client,
          ),
        );

        context.value.mutate(null);
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        completer.complete('data');
        await asyncYield();
        expect(context.value.status, MutationStatus.success);
        expect(context.value.data, 'data');
        context.dispose();
      });

      test(
          'SHOULD execute normally offline'
          '', () async {
        // Start offline
        connectivityController.add(false);
        await asyncYield();

        final completer = Completer<String>();
        final context = SimpleHookContext(
          () => useMutation<String, Object, void, void>(
            (_, __) async => completer.future,
            networkMode: NetworkMode.always,
            client: client,
          ),
        );
        expect(context.value.status, MutationStatus.idle);

        context.value.mutate(null);
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        completer.complete('data');
        await asyncYield();
        expect(context.value.status, MutationStatus.success);
        expect(context.value.data, 'data');
        context.dispose();
      });

      test(
          'SHOULD NOT pause on going offline'
          '', () async {
        // Start online
        connectivityController.add(true);
        await asyncYield();

        final completer = Completer<String>();
        final context = SimpleHookContext(
          () => useMutation<String, Object, void, void>(
            (_, __) async => completer.future,
            networkMode: NetworkMode.always,
            client: client,
          ),
        );

        context.value.mutate(null);
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        // Go offline
        connectivityController.add(false);
        await asyncYield();
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        completer.complete('data');
        await asyncYield();
        expect(context.value.status, MutationStatus.success);
        expect(context.value.data, 'data');
        context.dispose();
      });

      test(
          'SHOULD NOT pause retries on going offline'
          '', () {
        fakeAsync((async) {
          // Start online
          connectivityController.add(true);
          async.flushMicrotasks();

          var mutateFnCount = 0;
          final context = SimpleHookContext(
            () => useMutation<String, Object, void, void>(
              (_, __) async {
                mutateFnCount++;
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

          context.value.mutate(null);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(mutateFnCount, 1);

          // Go offline
          connectivityController.add(false);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(mutateFnCount, 1);

          // Should continue retrying
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(mutateFnCount, 2);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(mutateFnCount, 3);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(mutateFnCount, 4);
          expect(context.value.status, MutationStatus.error);
          context.dispose();
        });
      });
    });

    group('== NetworkMode.offlineFirst', () {
      // Always runs first execution, pauses retries offline

      test(
          'SHOULD execute initial mutation normally online'
          '', () async {
        // Start online
        connectivityController.add(true);
        await asyncYield();

        final completer = Completer<String>();
        final context = SimpleHookContext(
          () => useMutation<String, Object, void, void>(
            (_, __) async => completer.future,
            networkMode: NetworkMode.offlineFirst,
            client: client,
          ),
        );

        context.value.mutate(null);
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        completer.complete('data');
        await asyncYield();
        expect(context.value.status, MutationStatus.success);
        expect(context.value.data, 'data');
        context.dispose();
      });

      test(
          'SHOULD execute initial mutation normally offline'
          '', () async {
        // Start offline
        connectivityController.add(false);
        await asyncYield();

        final completer = Completer<String>();
        final context = SimpleHookContext(
          () => useMutation<String, Object, void, void>(
            (_, __) async => completer.future,
            networkMode: NetworkMode.offlineFirst,
            client: client,
          ),
        );
        expect(context.value.status, MutationStatus.idle);

        context.value.mutate(null);
        expect(context.value.status, MutationStatus.pending);
        expect(context.value.isPaused, isFalse);

        completer.complete('data');
        await asyncYield();
        expect(context.value.status, MutationStatus.success);
        expect(context.value.data, 'data');
        context.dispose();
      });

      test(
          'SHOULD pause retries offline, then resume on going online'
          '', () {
        fakeAsync((async) {
          // Start offline
          connectivityController.add(false);
          async.flushMicrotasks();

          var mutateFnCount = 0;
          final context = SimpleHookContext(
            () => useMutation<String, Object, void, void>(
              (_, __) async {
                mutateFnCount++;
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

          context.value.mutate(null);
          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(mutateFnCount, 1);

          // Should NOT retry when paused
          async.elapse(const Duration(days: 365));
          async.flushMicrotasks();
          expect(context.value.isPaused, isTrue);
          expect(mutateFnCount, 1);

          // Go online
          connectivityController.add(true);
          async.flushMicrotasks();
          expect(context.value.isPaused, isFalse);
          expect(mutateFnCount, 2);

          // Should continue retrying
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(mutateFnCount, 3);
          async.elapse(const Duration(seconds: 1));
          async.flushMicrotasks();
          expect(mutateFnCount, 4);
          expect(context.value.status, MutationStatus.error);
          context.dispose();
        });
      });
    });
  });
}
