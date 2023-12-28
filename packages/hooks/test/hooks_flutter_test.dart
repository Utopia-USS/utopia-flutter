import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class _TestWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = useState(0);

    useEffect(() {
      debugPrint(state.value.toString());
      return () => debugPrint('dispose ${state.value}');
    }, [state.value]);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () => state.value++,
        child: Text(state.value.toString()),
      ),
    );
  }
}

void main() {
  testWidgets("aa", (tester) async {
    await tester.pumpWidget(_TestWidget());
    await tester.tap(find.byType(Text));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byType(Text)).data, '1');
  });
}
