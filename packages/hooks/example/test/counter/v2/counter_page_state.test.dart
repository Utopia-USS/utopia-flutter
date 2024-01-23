import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/counter/v2/counter/state/counter_page_state.dart';

void main() {
  group("CounterPageState", () {
    late SimpleHookContext<CounterPageState> context;

    setUpAll(() {
      context = SimpleHookContext(useCounterPageState);
    });

    test("Should initialize with 0", () {
      expect(context().value, 0);
    });

    test("Should increment value", () {
      context().onPressed();
      expect(context().value, 1);
    });
  });
}
