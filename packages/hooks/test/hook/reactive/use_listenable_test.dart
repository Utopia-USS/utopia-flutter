import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  group("useListenable", () {
    late ListenableMutableValue<int> listenable;
    late SimpleHookContext<void> context;

    setUp(() {
      listenable = ListenableMutableValue(0);
      context = SimpleHookContext(shouldRebuild: false, () => useListenable(listenable));
    });

    test("should rebuild when listener is triggered", () {
      listenable.value = 1;
      expect(context.needsBuild, true);
    });

    test("should not rebuild when listener is triggered and shouldRebuild returns false", () {
      final context = SimpleHookContext(
        shouldRebuild: false,
        () => useListenable(listenable, shouldRebuild: () => false),
      );

      listenable.value = 1;
      expect(context.needsBuild, false);
    });
  });

  group("useListenableValue", () {
    late ListenableMutableValue<int> listenable;
    late SimpleHookContext<int> context;

    setUp(() {
      listenable = ListenableMutableValue(0);
      context = SimpleHookContext(shouldRebuild: false, () => useListenableValue(listenable));
    });

    test("should rebuild when value changes", () {
      listenable.value = 1;
      expect(context.needsBuild, true);

      context.rebuild();
      expect(context(), 1);
    });

    test("should not rebuild when value is equal to previous one", () {
      listenable.value = 0;
      expect(context.needsBuild, false);
    });

    test("should not rebuild when value changes but shouldRebuild returns false", () {
      context = SimpleHookContext(
        shouldRebuild: false,
        () => useListenableValue(listenable, shouldRebuild: (_, __) => false),
      );

      listenable.value = 1;
      expect(context.needsBuild, false);
    });
  });
}
