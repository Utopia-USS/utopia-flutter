import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _duration = Duration(milliseconds: 300);

void main() {
  Widget build({required int index, bool lazy = false, int childCount = 3}) => Directionality(
    textDirection: TextDirection.ltr,
    child: CrossFadeIndexedStack(
      duration: _duration,
      index: index,
      lazy: lazy,
      children: [for (var i = 0; i < childCount; i++) SizedBox.expand(child: Text('child $i'))],
    ),
  );

  List<AnimatedOpacity> opacitiesOf(WidgetTester tester) =>
      tester.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity)).toList();

  List<IgnorePointer> ignorePointersOf(WidgetTester tester) =>
      tester.widgetList<IgnorePointer>(find.byType(IgnorePointer)).toList();

  group('opacity', () {
    testWidgets('gives the selected child full opacity and the rest none', (tester) async {
      await tester.pumpWidget(build(index: 1));

      expect(opacitiesOf(tester).map((it) => it.opacity), [0.0, 1.0, 0.0]);
    });

    testWidgets('crossfades when the index changes', (tester) async {
      await tester.pumpWidget(build(index: 0));
      await tester.pumpAndSettle();

      await tester.pumpWidget(build(index: 2));
      await tester.pump();
      await tester.pump(_duration ~/ 2);

      final fades = tester.widgetList<FadeTransition>(find.byType(FadeTransition)).toList();
      expect(fades[0].opacity.value, closeTo(0.5, 0.001));
      expect(fades[2].opacity.value, closeTo(0.5, 0.001));

      await tester.pumpAndSettle();
      expect(opacitiesOf(tester).map((it) => it.opacity), [0.0, 0.0, 1.0]);
    });

    testWidgets('forwards the duration and the curve', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: CrossFadeIndexedStack(
            duration: _duration,
            curve: Curves.easeInOutCubic,
            index: 0,
            children: [SizedBox.shrink(), SizedBox.shrink()],
          ),
        ),
      );

      expect(opacitiesOf(tester).every((it) => it.duration == _duration), isTrue);
      expect(opacitiesOf(tester).every((it) => it.curve == Curves.easeInOutCubic), isTrue);
    });
  });

  group('pointer handling', () {
    testWidgets('ignores pointers for every non-selected index', (tester) async {
      await tester.pumpWidget(build(index: 1));

      expect(ignorePointersOf(tester).map((it) => it.ignoring), [true, false, true]);
    });

    testWidgets('moves the active hit target when the index changes', (tester) async {
      await tester.pumpWidget(build(index: 0));
      await tester.pumpWidget(build(index: 2));

      expect(ignorePointersOf(tester).map((it) => it.ignoring), [true, true, false]);
    });
  });

  group('lazy', () {
    testWidgets('builds every child eagerly when lazy is off', (tester) async {
      await tester.pumpWidget(build(index: 0));

      expect(find.text('child 0'), findsOneWidget);
      expect(find.text('child 1'), findsOneWidget);
      expect(find.text('child 2'), findsOneWidget);
    });

    testWidgets('does not build a child until its index has been selected', (tester) async {
      await tester.pumpWidget(build(index: 0, lazy: true));

      expect(find.text('child 0'), findsOneWidget);
      expect(find.text('child 1'), findsNothing);
      expect(find.text('child 2'), findsNothing);
      // The slots still exist, they are just empty.
      expect(opacitiesOf(tester), hasLength(3));
    });

    testWidgets('builds a child as soon as its index is selected', (tester) async {
      await tester.pumpWidget(build(index: 0, lazy: true));
      await tester.pumpWidget(build(index: 1, lazy: true));

      expect(find.text('child 1'), findsOneWidget);
      expect(find.text('child 2'), findsNothing);
    });

    testWidgets('keeps a child built after it has been deselected again', (tester) async {
      await tester.pumpWidget(build(index: 0, lazy: true));
      await tester.pumpWidget(build(index: 1, lazy: true));
      await tester.pumpWidget(build(index: 0, lazy: true));
      await tester.pumpAndSettle();

      expect(find.text('child 0'), findsOneWidget);
      expect(find.text('child 1'), findsOneWidget);
      expect(find.text('child 2'), findsNothing);
    });

    testWidgets('preserves the state of a child that is no longer selected', (tester) async {
      Widget build({required int index}) => Directionality(
        textDirection: TextDirection.ltr,
        child: CrossFadeIndexedStack(
          duration: _duration,
          index: index,
          lazy: true,
          children: const [
            _Counter(label: 'a'),
            _Counter(label: 'b'),
          ],
        ),
      );

      await tester.pumpWidget(build(index: 0));
      await tester.tap(find.text('a: 0'));
      await tester.pump();
      expect(find.text('a: 1'), findsOneWidget);

      await tester.pumpWidget(build(index: 1));
      await tester.pumpAndSettle();

      expect(find.text('a: 1'), findsOneWidget);
      expect(find.text('b: 0'), findsOneWidget);
    });
  });

  testWidgets('asserts when the number of children changes', (tester) async {
    await tester.pumpWidget(build(index: 0));

    await tester.pumpWidget(build(index: 0, childCount: 2));

    expect(tester.takeException(), isAssertionError);
  });
}

class _Counter extends StatefulWidget {
  final String label;

  const _Counter({required this.label});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => count++),
      child: ColoredBox(
        color: const Color(0xFF000000),
        child: Center(child: Text('${widget.label}: $count')),
      ),
    );
  }
}
