import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _topKey = ValueKey('top');
const _bottomKey = ValueKey('bottom');
const _viewport = Size(400, 600);
const _bottomHeight = 50.0;

void main() {
  void setUpViewport(WidgetTester tester) {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget build({required double topHeight, EdgeInsets padding = EdgeInsets.zero}) => Directionality(
    textDirection: TextDirection.ltr,
    child: TopBottomLayout(
      padding: padding,
      top: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(key: _topKey, height: topHeight, width: _viewport.width),
      ),
      bottom: const SizedBox(key: _bottomKey, height: _bottomHeight),
    ),
  );

  ScrollPosition positionOf(WidgetTester tester) => tester.state<ScrollableState>(find.byType(Scrollable)).position;

  group('content fits', () {
    testWidgets('spreads top and bottom over the full viewport height', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(build(topHeight: 100));

      expect(tester.getTopLeft(find.byKey(_topKey)).dy, 0);
      expect(tester.getBottomLeft(find.byKey(_topKey)).dy, 100);
      // The bottom is pushed all the way down, leaving a gap after the top.
      expect(tester.getTopLeft(find.byKey(_bottomKey)).dy, _viewport.height - _bottomHeight);
      expect(tester.getBottomLeft(find.byKey(_bottomKey)).dy, _viewport.height);
    });

    testWidgets('does not scroll', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(build(topHeight: 100));

      expect(positionOf(tester).maxScrollExtent, 0);
    });
  });

  group('content overflows', () {
    testWidgets('lays the bottom directly under the top with no gap', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(build(topHeight: 800));

      expect(tester.getBottomLeft(find.byKey(_topKey)).dy, 800);
      expect(tester.getTopLeft(find.byKey(_bottomKey)).dy, 800);
    });

    testWidgets('becomes scrollable', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(build(topHeight: 800));

      expect(positionOf(tester).maxScrollExtent, 800 + _bottomHeight - _viewport.height);

      await tester.drag(find.byType(TopBottomLayout), const Offset(0, -250));
      await tester.pumpAndSettle();

      expect(positionOf(tester).pixels, positionOf(tester).maxScrollExtent);
      expect(tester.getBottomLeft(find.byKey(_bottomKey)).dy, _viewport.height);
    });
  });

  testWidgets('applies the padding', (tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(build(topHeight: 100, padding: const EdgeInsets.fromLTRB(10, 20, 30, 40)));

    expect(tester.getTopLeft(find.byKey(_topKey)).dy, 20);
    expect(tester.getBottomLeft(find.byKey(_bottomKey)).dy, _viewport.height - 40);
    expect(tester.getSize(find.byKey(_topKey)).width, _viewport.width - 40);
  });

  testWidgets('forwards the scroll physics', (tester) async {
    setUpViewport(tester);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: TopBottomLayout(
          scrollPhysics: NeverScrollableScrollPhysics(),
          top: SizedBox(key: _topKey, height: 800),
          bottom: SizedBox(key: _bottomKey, height: _bottomHeight),
        ),
      ),
    );

    await tester.drag(find.byType(TopBottomLayout), const Offset(0, -250));
    await tester.pumpAndSettle();

    expect(positionOf(tester).pixels, 0);
  });
}
