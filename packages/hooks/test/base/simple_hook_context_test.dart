
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  test("SimpleHookContext", () {
    final context = SimpleHookContext(() {
      final state = useState(0);

      useEffect(() {
        if(state.value == 0) {
          state.value = 1;
        }
      }, [state.value]);

      return state.value;
    });

    expect(context(), 1);
  });
}
