import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/src/base/test/simple_hook_context.dart';
import 'package:utopia_hooks/src/hook/async/use_stream_subscription.dart';

void main() {
  group("useStreamSubscription", () {
    late StreamController<int> controller;
    late List<int> values;
    late SimpleHookContext<void> context;

    void setUp(StreamSubscriptionStrategy strategy) {
      controller = StreamController();
      values = [];
      context = SimpleHookContext(() {
        useStreamSubscription(
          controller.stream,
          (value) async => Future.delayed(const Duration(milliseconds: 100), () => values.add(value)),
          strategy: strategy,
        );
      });
    }

    tearDown(() {
      context.dispose();
      unawaited(controller.close());
    });

    test("strategy: parallel", () async {
      setUp(StreamSubscriptionStrategy.parallel);

      controller.add(1);
      controller.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(values, [1, 2]);
    });

    test("strategy: pause", () async {
      setUp(StreamSubscriptionStrategy.pause);

      controller.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.isPaused, true);

      controller.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(values, [1]);
      expect(controller.isPaused, true);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(values, [1, 2]);
      expect(controller.isPaused, false);
    });

    test("strategy: drop", () async {
      setUp(StreamSubscriptionStrategy.drop);

      controller.add(1);
      controller.add(2);

      await Future<void>.delayed(const Duration(milliseconds: 150));

      controller.add(3);
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(values, [1, 3]);
    });
  });
}
