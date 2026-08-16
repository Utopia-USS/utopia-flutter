import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _primaryKey = ValueKey('primary');
const _secondaryKey = ValueKey('secondary');
const _actionHeight = 40.0;
const _actionWidth = 120.0;

const _defaultChildren = <Widget>[
  SizedBox(key: _primaryKey, width: _actionWidth, height: _actionHeight),
  SizedBox(key: _secondaryKey, width: _actionWidth, height: _actionHeight),
];

void main() {
  /// [DialogActions] on its own, inside a box of an explicit [width] - the fallback path, with no dialog to ask.
  Widget buildStandalone({
    required double width,
    double spacing = 8,
    double fullscreenBreakpoint = AdaptiveDialog.defaultFullscreenBreakpoint,
    List<Widget> children = _defaultChildren,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: DialogActions(spacing: spacing, fullscreenBreakpoint: fullscreenBreakpoint, children: children),
        ),
      ),
    );
  }

  /// [DialogActions] inside an [AdaptiveDialog] of [dialogWidth], itself boxed to [actionsWidth] so that the two
  /// sources of truth (the scope and the widget's own width) can be made to disagree on purpose.
  Widget buildInDialog({required double dialogWidth, double actionsWidth = 200, double spacing = 8}) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: dialogWidth,
          height: 600,
          child: AdaptiveDialog(
            builder: (context, isFullscreen) => Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: actionsWidth,
                child: DialogActions(spacing: spacing, children: _defaultChildren),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder columnFinder() => find.descendant(of: find.byType(DialogActions), matching: find.byType(Column));

  Finder rowFinder() => find.descendant(of: find.byType(DialogActions), matching: find.byType(Row));

  group('fullscreen layout', () {
    testWidgets('is a Column that hugs its children and stretches them', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 400));

      expect(columnFinder(), findsOneWidget);
      expect(rowFinder(), findsNothing);

      final column = tester.widget<Column>(columnFinder());
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets('keeps the declared order, so the primary action stays on top', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 400));

      expect(tester.getTopLeft(find.byKey(_primaryKey)).dy, lessThan(tester.getTopLeft(find.byKey(_secondaryKey)).dy));
    });

    testWidgets('stretches the children to full width', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 400));

      expect(tester.getSize(find.byKey(_primaryKey)).width, 400);
      expect(tester.getSize(find.byKey(_secondaryKey)).width, 400);
    });

    testWidgets('leaves exactly spacing between the two actions', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 400, spacing: 24));

      final primaryBottom = tester.getBottomLeft(find.byKey(_primaryKey)).dy;
      expect(tester.getTopLeft(find.byKey(_secondaryKey)).dy - primaryBottom, 24);
    });
  });

  group('card layout', () {
    testWidgets('is a Row aligned to the end', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 800));

      expect(rowFinder(), findsOneWidget);
      expect(columnFinder(), findsNothing);
      expect(tester.widget<Row>(rowFinder()).mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('reverses the children, so the primary action ends up rightmost', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 800));

      expect(tester.getTopLeft(find.byKey(_secondaryKey)).dx, lessThan(tester.getTopLeft(find.byKey(_primaryKey)).dx));
      expect(tester.getTopRight(find.byKey(_primaryKey)).dx, 800);
    });

    testWidgets('keeps the intrinsic width of the children', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 800));

      expect(tester.getSize(find.byKey(_primaryKey)).width, _actionWidth);
    });

    testWidgets('leaves exactly spacing between the two actions', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 800, spacing: 24));

      final secondaryRight = tester.getTopRight(find.byKey(_secondaryKey)).dx;
      expect(tester.getTopLeft(find.byKey(_primaryKey)).dx - secondaryRight, 24);
    });
  });

  group('mode resolution', () {
    testWidgets('falls back to its own width when there is no enclosing dialog', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 599));
      expect(columnFinder(), findsOneWidget);

      await tester.pumpWidget(buildStandalone(width: 600));
      expect(rowFinder(), findsOneWidget);
    });

    testWidgets('honours a custom fullscreenBreakpoint in the fallback path', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 400, fullscreenBreakpoint: 300));
      expect(rowFinder(), findsOneWidget);

      await tester.pumpWidget(buildStandalone(width: 400, fullscreenBreakpoint: 500));
      expect(columnFinder(), findsOneWidget);
    });

    testWidgets('prefers the enclosing dialog over its own width', (tester) async {
      // A wide dialog, but the actions themselves only get 400px - self-measurement alone would say "fullscreen".
      await tester.pumpWidget(buildInDialog(dialogWidth: 700, actionsWidth: 400));

      expect(rowFinder(), findsOneWidget);
      expect(columnFinder(), findsNothing);
    });

    testWidgets('follows a fullscreen dialog even when the actions are given plenty of room', (tester) async {
      await tester.pumpWidget(buildInDialog(dialogWidth: 500, actionsWidth: 480));

      expect(columnFinder(), findsOneWidget);
      expect(rowFinder(), findsNothing);
    });
  });

  group('edge cases', () {
    testWidgets('renders a single action without any spacing', (tester) async {
      await tester.pumpWidget(
        buildStandalone(
          width: 400,
          spacing: 24,
          children: const [SizedBox(key: _primaryKey, height: _actionHeight)],
        ),
      );

      expect(tester.getSize(columnFinder()).height, _actionHeight);
    });

    testWidgets('does not throw on an empty children list', (tester) async {
      await tester.pumpWidget(buildStandalone(width: 400, children: const []));

      expect(tester.takeException(), isNull);
      expect(columnFinder(), findsOneWidget);
    });
  });
}
