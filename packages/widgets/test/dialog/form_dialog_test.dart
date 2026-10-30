import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _bottomKey = ValueKey('bottom');
const _bodyKey = ValueKey('body');
const _openText = 'open';
const _title = 'Title';

const _fullscreenSize = Size(400, 800);
const _cardSize = Size(900, 700);

void main() {
  FormDialog buildDialog({
    Widget? leading,
    Widget? trailing,
    bool dismissible = true,
    VoidCallback? onBackPressed,
    ScrollController? scrollController,
    Widget? title,
    Widget? sliver,
    Widget? bottom,
  }) {
    return FormDialog.raw(
      title: title ?? const Text(_title),
      leading: leading,
      trailing: trailing,
      dismissible: dismissible,
      onBackPressed: onBackPressed,
      scrollController: scrollController,
      sliver: sliver ?? const SliverToBoxAdapter(child: SizedBox(key: _bodyKey, height: 100)),
      bottom: bottom ?? const SizedBox(key: _bottomKey, height: 48),
    );
  }

  /// Pumps [child] directly, without a route - enough for everything that does not pop.
  Future<void> pump(WidgetTester tester, Widget child, {required Size size}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: child));
  }

  /// Pushes [child] as a real dialog route, so that the header's default pop behaviour has something to pop.
  Future<void> pumpAsRoute(WidgetTester tester, Widget child, {required Size size}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) =>
              TextButton(onPressed: () => AdaptiveDialog.show<void>(context, child), child: const Text(_openText)),
        ),
      ),
    );
    await tester.tap(find.text(_openText));
    await tester.pumpAndSettle();
  }

  group('default header buttons', () {
    testWidgets('fullscreen shows a back button and no close button', (tester) async {
      await pump(tester, buildDialog(), size: _fullscreenSize);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('card shows a close button and no back button', (tester) async {
      await pump(tester, buildDialog(), size: _cardSize);

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('dismissible false hides both, in both modes', (tester) async {
      await pump(tester, buildDialog(dismissible: false), size: _fullscreenSize);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);

      await pump(tester, buildDialog(dismissible: false), size: _cardSize);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('onBackPressed brings the back button into card mode too', (tester) async {
      await pump(tester, buildDialog(onBackPressed: () {}), size: _cardSize);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('onBackPressed shows the back button even when not dismissible', (tester) async {
      await pump(tester, buildDialog(dismissible: false, onBackPressed: () {}), size: _fullscreenSize);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('header button behaviour', () {
    testWidgets('the back button pops by default', (tester) async {
      await pumpAsRoute(tester, buildDialog(), size: _fullscreenSize);
      expect(find.byKey(_bodyKey), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byKey(_bodyKey), findsNothing);
    });

    testWidgets('the close button pops', (tester) async {
      await pumpAsRoute(tester, buildDialog(), size: _cardSize);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byKey(_bodyKey), findsNothing);
    });

    testWidgets('onBackPressed fires instead of popping', (tester) async {
      var called = 0;
      await pumpAsRoute(tester, buildDialog(onBackPressed: () => called++), size: _fullscreenSize);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(called, 1);
      expect(find.byKey(_bodyKey), findsOneWidget);
    });
  });

  group('header slots', () {
    testWidgets('an explicit leading replaces the default back button', (tester) async {
      await pump(
        tester,
        buildDialog(leading: const Icon(Icons.menu, key: ValueKey('leading'))),
        size: _fullscreenSize,
      );

      expect(find.byKey(const ValueKey('leading')), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('an explicit trailing replaces the default close button', (tester) async {
      await pump(
        tester,
        buildDialog(trailing: const Icon(Icons.help, key: ValueKey('trailing'))),
        size: _cardSize,
      );

      expect(find.byKey(const ValueKey('trailing')), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('a shrunk slot suppresses the default button', (tester) async {
      await pump(tester, buildDialog(leading: const SizedBox.shrink()), size: _fullscreenSize);

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });

  group('title', () {
    testWidgets('picks up the theme titleLarge', (tester) async {
      late TextStyle captured;
      late TextStyle? expected;
      await tester.pumpWidget(
        MaterialApp(
          home: buildDialog(
            title: Builder(
              builder: (context) {
                captured = DefaultTextStyle.of(context).style;
                // Read from the tree, not from a hand-built ThemeData - the font sizes only appear once the
                // typography has been localized, which happens inside MaterialApp.
                expected = Theme.of(context).textTheme.titleLarge;
                return const Text(_title);
              },
            ),
          ),
        ),
      );

      expect(expected?.fontSize, isNotNull);
      expect(captured.fontSize, expected!.fontSize);
    });

    testWidgets('a title bringing its own style wins', (tester) async {
      await pump(
        tester,
        buildDialog(title: const Text(_title, style: TextStyle(fontSize: 99))),
        size: _cardSize,
      );

      expect(tester.renderObject<RenderParagraph>(find.text(_title)).text.style!.fontSize, 99);
    });
  });

  group('body', () {
    testWidgets('raw renders the given sliver inside a FormLayout and a CustomScrollView', (tester) async {
      await pump(tester, buildDialog(), size: _cardSize);

      expect(find.byType(FormLayout), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byKey(_bodyKey), findsOneWidget);
      expect(find.byKey(_bottomKey), findsOneWidget);
    });

    testWidgets('simple wraps a box child into a sliver', (tester) async {
      await pump(
        tester,
        FormDialog.simple(
          title: const Text(_title),
          content: const SizedBox(key: _bodyKey, height: 100),
          bottom: const SizedBox(key: _bottomKey, height: 48),
        ),
        size: _cardSize,
      );

      expect(find.byType(FormLayout), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byKey(_bodyKey), findsOneWidget);
    });

    testWidgets('attaches the given scrollController and scrolls with it', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        buildDialog(
          scrollController: controller,
          sliver: const SliverToBoxAdapter(child: SizedBox(key: _bodyKey, height: 3000)),
        ),
        size: _cardSize,
      );

      expect(controller.hasClients, isTrue);
      controller.jumpTo(120);
      await tester.pump();

      expect(controller.offset, 120);
    });

    testWidgets('keeps the bottom pinned while the body scrolls', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        buildDialog(
          scrollController: controller,
          sliver: const SliverToBoxAdapter(child: SizedBox(key: _bodyKey, height: 3000)),
        ),
        size: _cardSize,
      );
      final before = tester.getTopLeft(find.byKey(_bottomKey));

      controller.jumpTo(200);
      await tester.pump();

      expect(tester.getTopLeft(find.byKey(_bottomKey)), before);
    });
  });

  group('composition with DialogActions', () {
    Finder actionsColumn() => find.descendant(of: find.byType(DialogActions), matching: find.byType(Column));

    Finder actionsRow() => find.descendant(of: find.byType(DialogActions), matching: find.byType(Row));

    const actions = DialogActions(
      children: [
        SizedBox(key: ValueKey('primary'), height: 40, width: 100),
        SizedBox(key: ValueKey('secondary'), height: 40, width: 100),
      ],
    );

    testWidgets('nested actions follow the dialog into fullscreen', (tester) async {
      await pump(tester, buildDialog(bottom: actions), size: _fullscreenSize);

      expect(actionsColumn(), findsOneWidget);
      expect(actionsRow(), findsNothing);
    });

    testWidgets('nested actions follow the dialog into card mode', (tester) async {
      await pump(tester, buildDialog(bottom: actions), size: _cardSize);

      expect(actionsRow(), findsOneWidget);
      expect(actionsColumn(), findsNothing);
    });
  });

  group('does not overflow', () {
    testWidgets('with a long title, a tall body and a tall bottom', (tester) async {
      await pump(
        tester,
        buildDialog(
          title: const Text('A title long enough to be an inconvenience for any header row layout'),
          sliver: const SliverToBoxAdapter(child: SizedBox(key: _bodyKey, height: 4000)),
          bottom: const SizedBox(key: _bottomKey, height: 200),
        ),
        size: _fullscreenSize,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('in card mode as well', (tester) async {
      await pump(
        tester,
        buildDialog(
          title: const Text('A title long enough to be an inconvenience for any header row layout'),
          sliver: const SliverToBoxAdapter(child: SizedBox(key: _bodyKey, height: 4000)),
          bottom: const SizedBox(key: _bottomKey, height: 200),
        ),
        size: _cardSize,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
