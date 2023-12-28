import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class StateA {
  final int a;
  final void Function() b;

  StateA({required this.a, required this.b});
}

StateA useA() {
  final a = useState(0);

  return StateA(a: a.value, b: () => a.value++);
}

class StateB {
  final int b;

  StateB({required this.b});
}

StateB useB() {
  final a = useProvided<StateA>();

  useEffect(() {
    debugPrint("A: ${a.a}");
    if(a.a < 9) Future.delayed(const Duration(seconds: 1), a.b);
    return null;
  }, [a.a]);

  return StateB(b: a.a + 1);
}

void main() {
  testWidgets("aa", (tester) async {
    final widget = HookProviderContainerWidget(
      const {StateA: useA, StateB: useB},
      child: HookBuilder(
        builder: (context) {
          final state = useProvided<StateB>();

          useEffect(() => debugPrint("B: ${state.b}"), [state.b]);

          return Directionality(textDirection: TextDirection.ltr, child: Text(state.b.toString()));
        },
      ),
    );
    await tester.pumpFrames(widget, const Duration(seconds: 10));
  });
}
