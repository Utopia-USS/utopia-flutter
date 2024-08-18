import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  test("useMap", () {
    final context = SimpleHookContext(() {
      final keys = useState({"a"});

      final map = useMap(keys.value, (it) => useState<String>(it));

      return (keys: keys, map: map);
    });

    expect(context().map["a"]!.value, "a");

    context().map["a"]!.value = "b";
    expect(context().map["a"]!.value, "b");

    context().keys.value = {"a", "b"};
    expect(context().map["a"]!.value, "b");
    expect(context().map["b"]!.value, "b");

    context().keys.value = {"a"};
    expect(context().map["a"]!.value, "b");
    expect(context().map["b"], null);
  });
}
