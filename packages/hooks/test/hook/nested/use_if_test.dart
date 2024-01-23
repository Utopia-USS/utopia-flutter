import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  test("useIf", () {
    var effect = false;
    final context = SimpleHookContext(() {
      final condition = useState(false);

      useIf(condition.value, () {
        useEffect(() {
          effect = true;
          return () => effect = false;
        });
      });

      return condition.set;
    });

    expect(effect, false);

    context.value(true);
    expect(effect, true);

    context.value(false);
    expect(effect, false);
  });
}
