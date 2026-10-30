import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _outerKey = ValueKey('outer');
const _middleKey = ValueKey('middle');
const _innerKey = ValueKey('inner');

void main() {
  setUp(() => _WrapperState.instanceCount = 0);

  Widget wrap(Widget child) => Directionality(
    textDirection: TextDirection.ltr,
    child: Align(alignment: Alignment.topLeft, child: child),
  );

  group('nesting', () {
    testWidgets('nests the builders in order, first entry outermost', (tester) async {
      await tester.pumpWidget(
        wrap(
          MultiWidget([
            (child) => Padding(key: _outerKey, padding: EdgeInsets.zero, child: child),
            (child) => Padding(key: _middleKey, padding: EdgeInsets.zero, child: child),
            (child) => Padding(key: _innerKey, padding: EdgeInsets.zero, child: child),
          ]),
        ),
      );

      expect(find.descendant(of: find.byKey(_outerKey), matching: find.byKey(_middleKey)), findsOneWidget);
      expect(find.descendant(of: find.byKey(_middleKey), matching: find.byKey(_innerKey)), findsOneWidget);
      expect(find.descendant(of: find.byKey(_innerKey), matching: find.byKey(_outerKey)), findsNothing);
    });

    testWidgets('passes an empty widget as the innermost child', (tester) async {
      await tester.pumpWidget(
        wrap(MultiWidget([(child) => Padding(key: _outerKey, padding: const EdgeInsets.all(8), child: child)])),
      );

      expect(tester.getSize(find.byKey(_outerKey)), const Size(16, 16));
    });

    testWidgets('renders an empty widget for an empty list', (tester) async {
      await tester.pumpWidget(wrap(MultiWidget(const [])));

      expect(tester.getSize(find.byType(MultiWidget)), Size.zero);
    });

    testWidgets('keyed nests the builders in the same order', (tester) async {
      await tester.pumpWidget(
        wrap(
          MultiWidget.keyed([
            MapEntry('outer', (child) => Padding(key: _outerKey, padding: EdgeInsets.zero, child: child)),
            MapEntry('inner', (child) => Padding(key: _innerKey, padding: EdgeInsets.zero, child: child)),
          ]),
        ),
      );

      expect(find.descendant(of: find.byKey(_outerKey), matching: find.byKey(_innerKey)), findsOneWidget);
    });
  });

  group('state preservation', () {
    Widget buildKeyed({required bool includeMiddle}) => wrap(
      MultiWidget.keyed([
        MapEntry('a', (child) => _Wrapper(label: 'a', child: child)),
        if (includeMiddle) MapEntry('b', (child) => _Wrapper(label: 'b', child: child)),
        MapEntry('c', (child) => _Wrapper(label: 'c', child: child)),
      ]),
    );

    Widget buildUnkeyed({required bool includeMiddle}) => wrap(
      MultiWidget([
        (child) => _Wrapper(label: 'a', child: child),
        if (includeMiddle) (child) => _Wrapper(label: 'b', child: child),
        (child) => _Wrapper(label: 'c', child: child),
      ]),
    );

    testWidgets('keyed keeps sibling state when a middle entry is inserted', (tester) async {
      await tester.pumpWidget(buildKeyed(includeMiddle: false));
      expect(find.text('a#1'), findsOneWidget);
      expect(find.text('c#2'), findsOneWidget);

      await tester.pumpWidget(buildKeyed(includeMiddle: true));

      expect(find.text('a#1'), findsOneWidget);
      expect(find.text('b#3'), findsOneWidget);
      // `c` kept its State even though a new wrapper was pushed above it.
      expect(find.text('c#2'), findsOneWidget);
    });

    testWidgets('keyed keeps sibling state when a middle entry is removed', (tester) async {
      await tester.pumpWidget(buildKeyed(includeMiddle: true));
      expect(find.text('a#1'), findsOneWidget);
      expect(find.text('b#2'), findsOneWidget);
      expect(find.text('c#3'), findsOneWidget);

      await tester.pumpWidget(buildKeyed(includeMiddle: false));

      expect(find.text('a#1'), findsOneWidget);
      expect(find.text('b#2'), findsNothing);
      expect(find.text('c#3'), findsOneWidget);
    });

    testWidgets('keyed preserves mutable state of a stateful sibling across the toggle', (tester) async {
      await tester.pumpWidget(buildKeyed(includeMiddle: false));
      await tester.tap(find.text('c#2'));
      await tester.pump();
      expect(find.text('c#2 (tapped 1)'), findsOneWidget);

      await tester.pumpWidget(buildKeyed(includeMiddle: true));

      expect(find.text('c#2 (tapped 1)'), findsOneWidget);
    });

    testWidgets('unkeyed loses sibling state when a middle entry is inserted', (tester) async {
      await tester.pumpWidget(buildUnkeyed(includeMiddle: false));
      expect(find.text('a#1'), findsOneWidget);
      expect(find.text('c#2'), findsOneWidget);

      await tester.pumpWidget(buildUnkeyed(includeMiddle: true));

      expect(find.text('c#2'), findsNothing);
      expect(find.text('c#3'), findsOneWidget);
    });
  });
}

class _Wrapper extends StatefulWidget {
  final String label;
  final Widget child;

  const _Wrapper({required this.label, required this.child});

  @override
  State<_Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<_Wrapper> {
  static int instanceCount = 0;

  late final int instanceId = ++instanceCount;
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {
    final label = tapCount == 0 ? '${widget.label}#$instanceId' : '${widget.label}#$instanceId (tapped $tapCount)';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(onTap: () => setState(() => tapCount++), child: Text(label)),
        widget.child,
      ],
    );
  }
}
