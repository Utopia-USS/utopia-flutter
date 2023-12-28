import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  group("StatelessPageControllerWrapper", () {
    testWidgets("should initialize with given page", (tester) async {
      await tester.pumpWidget(_buildWidget(MutableValue(1)));
      await tester.pumpAndSettle();

      expect(_findPageView(tester).controller.page, 1);
    });

    testWidgets("should move to given page", (tester) async {
      final index = MutableValue(0);
      await tester.pumpWidget(_buildWidget(index));

      index.value = 1;
      await tester.pumpWidget(
        _buildWidget(
          index,
          onTransition: (controller, index) => controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          ),
        ),
      );

      expect(_findPageView(tester).controller.page, 0);

      await tester.pumpAndSettle();

      expect(_findPageView(tester).controller.page, 1);
    });

    testWidgets("should reflect when user changes page", (tester) async {
      final index = MutableValue(0);

      await tester.pumpWidget(_buildWidget(index));
      await tester.drag(find.byType(PageView), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      expect(_findPageView(tester).controller.page, 1);
      expect(index.value, 1);
    });
  });
}

Widget _buildWidget(MutableValue<int> index, {void Function(PageController controller, int index)? onTransition}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: StatelessPageControllerWrapper(
      index: index,
      onTransition: onTransition,
      builder: (controller) => PageView(
        controller: controller,
        children: [Container(), Container()],
      ),
    ),
  );
}

PageView _findPageView(WidgetTester tester) => tester.widget(find.byType(PageView));
