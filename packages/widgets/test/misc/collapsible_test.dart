import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _duration = Duration(milliseconds: 200);
const _childWidth = 80.0;
const _childHeight = 100.0;

void main() {
  Widget wrap(Widget child) => Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  );

  Widget buildVertical({required bool isExpanded, Curve? curve}) => wrap(
    curve == null
        ? Collapsible.vertical(
            duration: _duration,
            isExpanded: isExpanded,
            child: const SizedBox(width: _childWidth, height: _childHeight),
          )
        : Collapsible.vertical(
            duration: _duration,
            curve: curve,
            isExpanded: isExpanded,
            child: const SizedBox(width: _childWidth, height: _childHeight),
          ),
  );

  Widget buildHorizontal({required bool isExpanded}) => wrap(
    Collapsible.horizontal(
      duration: _duration,
      isExpanded: isExpanded,
      child: const SizedBox(width: _childWidth, height: _childHeight),
    ),
  );

  AnimatedAlign alignOf(WidgetTester tester) => tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));

  group('axis', () {
    testWidgets('vertical sets heightFactor and leaves widthFactor null', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: true));

      expect(alignOf(tester).heightFactor, 1.0);
      expect(alignOf(tester).widthFactor, isNull);
    });

    testWidgets('horizontal sets widthFactor and leaves heightFactor null', (tester) async {
      await tester.pumpWidget(buildHorizontal(isExpanded: true));

      expect(alignOf(tester).widthFactor, 1.0);
      expect(alignOf(tester).heightFactor, isNull);
    });

    testWidgets('the unnamed constructor honours the axis argument', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Collapsible(
            duration: _duration,
            axis: Axis.horizontal,
            isExpanded: true,
            child: SizedBox(width: _childWidth, height: _childHeight),
          ),
        ),
      );

      expect(alignOf(tester).widthFactor, 1.0);
      expect(alignOf(tester).heightFactor, isNull);
    });

    testWidgets('collapsed sets the factor to 0', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: false));

      expect(alignOf(tester).heightFactor, 0.0);
    });
  });

  group('sizing', () {
    testWidgets('vertical collapses the height to 0 and expands it back to the child height', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: false));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Collapsible)).height, 0);

      await tester.pumpWidget(buildVertical(isExpanded: true));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Collapsible)).height, _childHeight);
    });

    testWidgets('horizontal collapses the width to 0 and expands it back to the child width', (tester) async {
      await tester.pumpWidget(buildHorizontal(isExpanded: false));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Collapsible)).width, 0);

      await tester.pumpWidget(buildHorizontal(isExpanded: true));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Collapsible)).width, _childWidth);
    });

    testWidgets('clips the child while collapsing', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: true));

      expect(find.descendant(of: find.byType(AnimatedAlign), matching: find.byType(ClipRect)), findsOneWidget);
    });
  });

  group('animation', () {
    testWidgets('animates over the given duration instead of jumping', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: false, curve: Curves.linear));
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildVertical(isExpanded: true, curve: Curves.linear));
      await tester.pump();
      expect(tester.getSize(find.byType(Collapsible)).height, 0);

      await tester.pump(_duration ~/ 2);
      final midHeight = tester.getSize(find.byType(Collapsible)).height;
      expect(midHeight, closeTo(_childHeight / 2, 0.001));

      await tester.pump(_duration ~/ 2);
      expect(tester.getSize(find.byType(Collapsible)).height, _childHeight);
    });
  });

  group('curve', () {
    testWidgets('defaults to Curves.decelerate', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: true));

      expect(alignOf(tester).curve, Curves.decelerate);
    });

    testWidgets('forwards a custom curve to AnimatedAlign', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: true, curve: Curves.easeInOutCubic));

      expect(alignOf(tester).curve, Curves.easeInOutCubic);
    });

    testWidgets('honours the custom curve while animating', (tester) async {
      await tester.pumpWidget(buildVertical(isExpanded: false, curve: Curves.easeIn));
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildVertical(isExpanded: true, curve: Curves.easeIn));
      await tester.pump();
      await tester.pump(_duration ~/ 2);

      final expected = _childHeight * Curves.easeIn.transform(0.5);
      expect(tester.getSize(find.byType(Collapsible)).height, closeTo(expected, 0.001));
      // Sanity check: the curve actually bends the animation away from linear.
      expect(expected, lessThan(_childHeight / 2 - 1));
    });
  });
}
