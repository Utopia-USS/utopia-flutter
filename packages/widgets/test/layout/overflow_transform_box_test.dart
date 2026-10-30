import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _childKey = ValueKey('child');
const _boxSize = Size(300, 200);
const _childSize = Size(500, 400);

void main() {
  Widget build({
    required BoxConstraintsTransform transform,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Directionality(
      textDirection: textDirection,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(
          size: _boxSize,
          child: OverflowTransformBox(
            alignment: alignment,
            transform: transform,
            child: const SizedBox.shrink(key: _childKey),
          ),
        ),
      ),
    );
  }

  BoxConstraintsTransform tightTo(Size size) =>
      (_) => BoxConstraints.tight(size);

  testWidgets('is sized by the parent and takes constraints.biggest', (tester) async {
    await tester.pumpWidget(build(transform: tightTo(_childSize)));

    expect(tester.getSize(find.byType(OverflowTransformBox)), _boxSize);
  });

  testWidgets('takes constraints.biggest even when the child is smaller', (tester) async {
    await tester.pumpWidget(build(transform: tightTo(const Size(20, 10))));

    expect(tester.getSize(find.byType(OverflowTransformBox)), _boxSize);
    expect(tester.getSize(find.byKey(_childKey)), const Size(20, 10));
  });

  testWidgets('lays the child out with the transformed constraints so it may overflow', (tester) async {
    await tester.pumpWidget(build(transform: tightTo(_childSize)));

    expect(tester.getSize(find.byKey(_childKey)), _childSize);
  });

  testWidgets('passes the incoming constraints to the transform', (tester) async {
    late BoxConstraints received;
    await tester.pumpWidget(
      build(
        transform: (constraints) {
          received = constraints;
          return BoxConstraints.tight(_childSize);
        },
      ),
    );

    expect(received, BoxConstraints.tight(_boxSize));
  });

  group('alignment', () {
    testWidgets('centers the overflowing child by default', (tester) async {
      await tester.pumpWidget(build(transform: tightTo(_childSize)));

      expect(
        tester.getTopLeft(find.byKey(_childKey)),
        Offset((_boxSize.width - _childSize.width) / 2, (_boxSize.height - _childSize.height) / 2),
      );
    });

    testWidgets('honours Alignment.topLeft', (tester) async {
      await tester.pumpWidget(build(transform: tightTo(_childSize), alignment: Alignment.topLeft));

      expect(tester.getTopLeft(find.byKey(_childKey)), Offset.zero);
    });

    testWidgets('honours Alignment.bottomRight', (tester) async {
      await tester.pumpWidget(build(transform: tightTo(_childSize), alignment: Alignment.bottomRight));

      expect(
        tester.getTopLeft(find.byKey(_childKey)),
        Offset(_boxSize.width - _childSize.width, _boxSize.height - _childSize.height),
      );
    });

    testWidgets('resolves a directional alignment against the text direction', (tester) async {
      await tester.pumpWidget(
        build(
          transform: tightTo(_childSize),
          alignment: AlignmentDirectional.topStart,
          textDirection: TextDirection.rtl,
        ),
      );

      expect(tester.getTopLeft(find.byKey(_childKey)).dx, _boxSize.width - _childSize.width);
    });

    testWidgets('updates the alignment on rebuild', (tester) async {
      await tester.pumpWidget(build(transform: tightTo(_childSize), alignment: Alignment.topLeft));
      expect(tester.getTopLeft(find.byKey(_childKey)), Offset.zero);

      await tester.pumpWidget(build(transform: tightTo(_childSize), alignment: Alignment.bottomRight));
      expect(
        tester.getTopLeft(find.byKey(_childKey)),
        Offset(_boxSize.width - _childSize.width, _boxSize.height - _childSize.height),
      );
    });
  });

  testWidgets('picks up a new transform on rebuild', (tester) async {
    await tester.pumpWidget(build(transform: tightTo(_childSize)));
    expect(tester.getSize(find.byKey(_childKey)), _childSize);

    await tester.pumpWidget(build(transform: tightTo(const Size(50, 25))));

    expect(tester.getSize(find.byKey(_childKey)), const Size(50, 25));
  });
}
