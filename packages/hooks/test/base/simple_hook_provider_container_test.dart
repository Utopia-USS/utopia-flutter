import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class _State {
  final ComputedState<int> xd;

  const _State(this.xd);
}

void main() {
  group("SimpleHookProviderContainer", () {
    test("base case", () async {
      final container = SimpleHookProviderContainer({
        _State: () => _State(useAutoComputedState(() async => 1)),
      });

      expect(container.get<_State>().xd.valueOrNull, null);
      await container.waitUntil<_State>((it) => it.xd.valueOrNull == 1);
    });

    test("dependency accessed inside useIf is tracked after condition becomes true", () {
      // On first build gate=false → useIf block skipped → MutableValue<int> never registered
      // as a dependency of String. After gate flips true, changes to MutableValue<int> must
      // propagate to String.
      final container = SimpleHookProviderContainer({
        MutableValue<bool>: () => useState(false),
        MutableValue<int>: () => useState(0),
        String: () {
          final gate = useProvided<MutableValue<bool>>().value;
          return useIf(gate, () => 'value=${useProvided<MutableValue<int>>().value}') ?? 'none';
        },
      });

      expect(container.get<String>(), 'none');

      container.get<MutableValue<bool>>().value = true;
      expect(container.get<String>(), 'value=0');

      container.get<MutableValue<int>>().value = 42;
      expect(container.get<String>(), 'value=42');
    });

    test("consistent state on exception", () async {
      var effectCount = 0;

      var errorReported = false;

      FlutterError.onError = (_) => errorReported = true;

      final container = SimpleHookProviderContainer({
        MutableValue<int>: () => useState(0),
        String: () => useProvided<MutableValue<int>>().value == 0 ? throw Exception("Not good") : "All good",
        #test: () => useProvided<String>().also((_) => effectCount++),
      });

      expect(errorReported, true);

      expect(() => container.get<String>(), throwsA(isA<FlutterError>()));
      expect(effectCount, 0);

      container.get<MutableValue<int>>().value = 1;
      expect(container.get<String>(), "All good");
      expect(effectCount, 1);

      container.get<MutableValue<int>>().value = 0;
      expect(effectCount, 1);
      expect(container.get<String>(), "All good");

      container.get<MutableValue<int>>().value = 1;
      expect(container.get<String>(), "All good");
      expect(effectCount, 2);
    });
  });
}
