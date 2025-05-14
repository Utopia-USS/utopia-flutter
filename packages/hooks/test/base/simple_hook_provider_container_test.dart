import 'package:flutter/cupertino.dart';
import 'package:test/test.dart';
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

    test("consistent state on exception", () async {
      var effectCount = 0;
      final container = SimpleHookProviderContainer({
        MutableValue<int>: () => useState(0),
        String: () => useProvided<MutableValue<int>>().value == 0 ? throw Exception("Not good") : "All good",
        #test: () => useProvided<String>().also((_) => effectCount++),
      });

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
