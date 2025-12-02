import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/src/base/test/simple_hook_context.dart';
import 'package:utopia_hooks/src/hook/misc/use_previous.dart';

void main() {
  group("usePrevious hooks test", () {
    test("usePreviousValue", () {
      var value = 0;
      final context = SimpleHookContext(() => usePreviousValue(value));

      expect(context.value, null);

      context.rebuild();
      expect(context.value, null);

      value = 1;
      context.rebuild();
      expect(context.value, 0);

      context.rebuild();
      expect(context.value, 0);
    });
  });
}
