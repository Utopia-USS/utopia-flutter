import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _outsideKey = ValueKey('outside');

void main() {
  late FocusNode focusNode;

  setUp(() => focusNode = FocusNode());
  tearDown(() => focusNode.dispose());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: UnfocusOnTap(
        child: Scaffold(
          body: Column(
            children: [
              TextField(focusNode: focusNode),
              const SizedBox(
                key: _outsideKey,
                height: 200,
                width: 200,
                child: ColoredBox(color: Color(0xFF00FF00)),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  testWidgets('renders its child', (tester) async {
    await pump(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byKey(_outsideKey), findsOneWidget);
  });

  testWidgets('unfocuses a focused text field when tapping outside of it', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.byKey(_outsideKey));
    await tester.pumpAndSettle();

    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('is a no-op when nothing is focused', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(_outsideKey));
    await tester.pumpAndSettle();

    expect(focusNode.hasFocus, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not add itself to the semantics tree', (tester) async {
    await pump(tester);

    final gestureDetector = tester.widget<GestureDetector>(
      find.descendant(of: find.byType(UnfocusOnTap), matching: find.byType(GestureDetector)).first,
    );

    expect(gestureDetector.excludeFromSemantics, isTrue);
  });

  testWidgets('the deprecated UnFocusOnTap alias still resolves to UnfocusOnTap', (tester) async {
    // ignore: deprecated_member_use_from_same_package
    const widget = UnFocusOnTap(child: SizedBox.shrink());

    expect(widget, isA<UnfocusOnTap>());

    await tester.pumpWidget(const MaterialApp(home: widget));
    expect(find.byType(UnfocusOnTap), findsOneWidget);
  });
}
