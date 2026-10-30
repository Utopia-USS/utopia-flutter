import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _childKey = ValueKey('child');

void main() {
  Widget buildLoose({
    required double min,
    required double max,
    double maxWidth = 200,
    double maxHeight = 100,
    Alignment? alignment,
  }) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: ConstrainedAspectRatio(
          min: min,
          max: max,
          alignment: alignment,
          child: const SizedBox.expand(key: _childKey),
        ),
      ),
    );
  }

  group('sizing', () {
    testWidgets('uses constraints.biggest when the source ratio is inside the range', (tester) async {
      // 200x100 -> source ratio 2, which is inside [0.5, 4]
      await tester.pumpWidget(buildLoose(min: 0.5, max: 4));

      expect(tester.getSize(find.byType(ConstrainedAspectRatio)), const Size(200, 100));
    });

    testWidgets('letterboxes down to the min ratio when the source ratio is below min', (tester) async {
      // 200x100 -> source ratio 2 < 3, so height shrinks to 200 / 3
      await tester.pumpWidget(buildLoose(min: 3, max: 4));

      final size = tester.getSize(find.byType(ConstrainedAspectRatio));
      expect(size.width, 200);
      expect(size.height, closeTo(200 / 3, 0.001));
      expect(size.width / size.height, closeTo(3, 0.001));
    });

    testWidgets('pillarboxes down to the max ratio when the source ratio is above max', (tester) async {
      // 200x100 -> source ratio 2 > 1, so width shrinks to 100 * 1
      await tester.pumpWidget(buildLoose(min: 0.25, max: 1));

      final size = tester.getSize(find.byType(ConstrainedAspectRatio));
      expect(size, const Size(100, 100));
      expect(size.width / size.height, closeTo(1, 0.001));
    });

    testWidgets('returns constraints.biggest when the incoming constraints are tight', (tester) async {
      await tester.pumpWidget(
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            height: 100,
            child: ConstrainedAspectRatio(min: 0.25, max: 1, child: SizedBox.expand(key: _childKey)),
          ),
        ),
      );

      expect(tester.getSize(find.byType(ConstrainedAspectRatio)), const Size(200, 100));
    });
  });

  group('alignment', () {
    testWidgets('shrinks to the child size when alignment is null', (tester) async {
      await tester.pumpWidget(buildLoose(min: 3, max: 4));

      expect(tester.getSize(find.byType(ConstrainedAspectRatio)), tester.getSize(find.byKey(_childKey)));
      expect(tester.getTopLeft(find.byKey(_childKey)), Offset.zero);
    });

    testWidgets('takes constraints.biggest and centers the child when alignment is set', (tester) async {
      await tester.pumpWidget(buildLoose(min: 0.25, max: 1, alignment: Alignment.center));

      expect(tester.getSize(find.byType(ConstrainedAspectRatio)), const Size(200, 100));
      expect(tester.getSize(find.byKey(_childKey)), const Size(100, 100));
      // (200 - 100) / 2 horizontally, (100 - 100) / 2 vertically
      expect(tester.getTopLeft(find.byKey(_childKey)), const Offset(50, 0));
    });

    testWidgets('aligns the child to the bottom right when asked to', (tester) async {
      await tester.pumpWidget(buildLoose(min: 0.25, max: 1, alignment: Alignment.bottomRight));

      expect(tester.getTopLeft(find.byKey(_childKey)), const Offset(100, 0));
      expect(tester.getBottomRight(find.byKey(_childKey)), const Offset(200, 100));
    });

    testWidgets('loosens tight constraints before computing the child size when alignment is set', (tester) async {
      await tester.pumpWidget(
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            height: 100,
            child: ConstrainedAspectRatio(
              min: 0.25,
              max: 1,
              alignment: Alignment.topLeft,
              child: SizedBox.expand(key: _childKey),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(ConstrainedAspectRatio)), const Size(200, 100));
      expect(tester.getSize(find.byKey(_childKey)), const Size(100, 100));
      expect(tester.getTopLeft(find.byKey(_childKey)), Offset.zero);
    });
  });

  group('intrinsics', () {
    Future<RenderBox> pumpWithChild(WidgetTester tester) async {
      await tester.pumpWidget(
        const Align(
          alignment: Alignment.topLeft,
          child: ConstrainedAspectRatio(min: 1, max: 2, child: SizedBox(width: 100, height: 50)),
        ),
      );
      return tester.renderObject<RenderBox>(find.byType(ConstrainedAspectRatio));
    }

    testWidgets('clamps the child intrinsic width into height * [min, max]', (tester) async {
      final renderObject = await pumpWithChild(tester);

      // child reports 100, clamped into [40 * 1, 40 * 2]
      expect(renderObject.getMinIntrinsicWidth(40), 80);
      expect(renderObject.getMaxIntrinsicWidth(40), 80);
      // child reports 100, which already fits into [50 * 1, 50 * 2]
      expect(renderObject.getMinIntrinsicWidth(50), 100);
      expect(renderObject.getMaxIntrinsicWidth(50), 100);
    });

    testWidgets('clamps the child intrinsic height into width / [max, min]', (tester) async {
      final renderObject = await pumpWithChild(tester);

      // child reports 50, clamped into [300 / 2, 300 / 1]
      expect(renderObject.getMinIntrinsicHeight(300), 150);
      expect(renderObject.getMaxIntrinsicHeight(300), 150);
      // child reports 50, which already fits into [80 / 2, 80 / 1]
      expect(renderObject.getMinIntrinsicHeight(80), 50);
      expect(renderObject.getMaxIntrinsicHeight(80), 50);
    });

    testWidgets('returns the raw child intrinsic width for an infinite height', (tester) async {
      final renderObject = await pumpWithChild(tester);

      expect(renderObject.getMinIntrinsicWidth(double.infinity), 100);
      expect(renderObject.getMaxIntrinsicWidth(double.infinity), 100);
    });

    testWidgets('returns the raw child intrinsic height for an infinite width', (tester) async {
      final renderObject = await pumpWithChild(tester);

      expect(renderObject.getMinIntrinsicHeight(double.infinity), 50);
      expect(renderObject.getMaxIntrinsicHeight(double.infinity), 50);
    });

    testWidgets('falls back to 0 / infinity when there is no child', (tester) async {
      await tester.pumpWidget(const Align(alignment: Alignment.topLeft, child: ConstrainedAspectRatio(min: 1, max: 2)));
      final renderObject = tester.renderObject<RenderBox>(find.byType(ConstrainedAspectRatio));

      // 0 clamped into [40, 80] and infinity clamped into [40, 80]
      expect(renderObject.getMinIntrinsicWidth(40), 40);
      expect(renderObject.getMaxIntrinsicWidth(40), 80);
      // 0 clamped into [150, 300] and infinity clamped into [150, 300]
      expect(renderObject.getMinIntrinsicHeight(300), 150);
      expect(renderObject.getMaxIntrinsicHeight(300), 300);
    });
  });

  group('render object updates', () {
    testWidgets('relayouts when the range changes', (tester) async {
      await tester.pumpWidget(buildLoose(min: 0.5, max: 4));
      expect(tester.getSize(find.byType(ConstrainedAspectRatio)), const Size(200, 100));

      await tester.pumpWidget(buildLoose(min: 0.25, max: 1));
      expect(tester.getSize(find.byType(ConstrainedAspectRatio)), const Size(100, 100));
    });

    testWidgets('relayouts when the alignment changes', (tester) async {
      await tester.pumpWidget(buildLoose(min: 0.25, max: 1, alignment: Alignment.topLeft));
      expect(tester.getTopLeft(find.byKey(_childKey)), Offset.zero);

      await tester.pumpWidget(buildLoose(min: 0.25, max: 1, alignment: Alignment.topRight));
      expect(tester.getTopLeft(find.byKey(_childKey)), const Offset(100, 0));
    });
  });
}
