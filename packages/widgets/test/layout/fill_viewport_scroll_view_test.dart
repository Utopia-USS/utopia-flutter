import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _childKey = ValueKey('child');
const _viewport = Size(400, 600);

void main() {
  void setUpViewport(WidgetTester tester) {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget build({required Widget child, Axis scrollDirection = Axis.vertical}) => Directionality(
    textDirection: TextDirection.ltr,
    child: FillViewportScrollView(scrollDirection: scrollDirection, child: child),
  );

  ScrollPosition positionOf(WidgetTester tester) => tester.state<ScrollableState>(find.byType(Scrollable)).position;

  group('vertical', () {
    testWidgets('stretches a short child to the full viewport height', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(build(child: const SizedBox(key: _childKey, height: 100)));

      expect(tester.getSize(find.byKey(_childKey)).height, _viewport.height);
      expect(positionOf(tester).maxScrollExtent, 0);
    });

    testWidgets('leaves a tall child at its own height and scrolls', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(build(child: const SizedBox(key: _childKey, height: 900)));

      expect(tester.getSize(find.byKey(_childKey)).height, 900);
      expect(positionOf(tester).maxScrollExtent, 900 - _viewport.height);

      await tester.drag(find.byType(FillViewportScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(positionOf(tester).pixels, greaterThan(0));
      expect(tester.getTopLeft(find.byKey(_childKey)).dy, lessThan(0));
    });
  });

  group('horizontal', () {
    testWidgets('stretches a narrow child to the full viewport width', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(
        build(
          scrollDirection: Axis.horizontal,
          child: const SizedBox(key: _childKey, width: 100),
        ),
      );

      expect(tester.getSize(find.byKey(_childKey)).width, _viewport.width);
      expect(positionOf(tester).maxScrollExtent, 0);
    });

    testWidgets('leaves a wide child at its own width and scrolls', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(
        build(
          scrollDirection: Axis.horizontal,
          child: const SizedBox(key: _childKey, width: 900),
        ),
      );

      expect(tester.getSize(find.byKey(_childKey)).width, 900);
      expect(positionOf(tester).maxScrollExtent, 900 - _viewport.width);

      await tester.drag(find.byType(FillViewportScrollView), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(positionOf(tester).pixels, greaterThan(0));
      expect(tester.getTopLeft(find.byKey(_childKey)).dx, lessThan(0));
    });
  });

  testWidgets('forwards the scroll physics', (tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FillViewportScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: SizedBox(key: _childKey, height: 900),
        ),
      ),
    );

    await tester.drag(find.byType(FillViewportScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(positionOf(tester).pixels, 0);
  });

  testWidgets('honours reverse', (tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FillViewportScrollView(reverse: true, child: SizedBox(key: _childKey, height: 900)),
      ),
    );

    // With reverse the child is anchored to the bottom of the viewport.
    expect(tester.getBottomLeft(find.byKey(_childKey)).dy, _viewport.height);
  });
}
