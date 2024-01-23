import 'package:test/test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  test("usePreviousIfNull", () {
    final context = SimpleHookContext(() {
      final state = useState<int?>(null);

      final value = usePreviousIfNull(state.value);

      return (value: value, set: state.set);
    });

    expect(context.value.value, null);

    context.value.set(1);
    expect(context.value.value, 1);

    context.value.set(null);
    expect(context.value.value, 1);

    context.value.set(2);
    expect(context.value.value, 2);
  });
}
