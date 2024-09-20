import 'package:test/test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class StateA {
  final int a;
  final void Function() b;

  StateA({required this.a, required this.b});
}

StateA useA() {
  final a = useState(0);

  return StateA(a: a.value, b: () => a.value = 1);
}

class StateB {
  final int b;

  StateB({required this.b});
}

StateB useB() {
  final a = useProvided<StateA>();
  final ext = useProvided<int>();

  useEffect(() {
    if(a.a == 0) Future.delayed(const Duration(seconds: 1), a.b);
    return null;
  }, [a.a]);

  return StateB(b: a.a + ext);
}

void main() {
  test("aa", () async {
    final container = SimpleHookProviderContainer({StateA: useA, StateB: useB}, provided: {int: 1});
    expect(container<StateB>().b, 1);
    await container.waitUntil<StateB>((it) => it.b == 2);
    container.setProvided<int>(2);
    expect(container<StateB>().b, 3);
  });
}
