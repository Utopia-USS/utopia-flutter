import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  late SimpleHookContext<ListenableNotifiable> context;

  group("useNotifiable()", () {
    setUp(() => context = SimpleHookContext(shouldRebuild: false, useNotifiable));

    test("should rebuild when notified", () {
      context().notify();
      expect(context.needsBuild, true);
    });

    test("should notify listeners when notified", () {
      var notified = false;
      context().addListener(() => notified = true);
      context().notify();
      expect(notified, true);
    });
  });
}
