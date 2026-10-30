import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _contentKey = ValueKey('content');
const _openText = 'open';

void main() {
  Future<void> pump(WidgetTester tester, Widget widget, {Size size = const Size(800, 600)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
  }

  AdaptiveDialog dialog({
    double fullscreenBreakpoint = AdaptiveDialog.defaultFullscreenBreakpoint,
    double maxWidth = AdaptiveDialog.defaultMaxWidth,
    double maxHeight = AdaptiveDialog.defaultMaxHeight,
    EdgeInsetsGeometry padding = AdaptiveDialog.defaultPadding,
    Color? backgroundColor,
    // ignore: avoid_positional_boolean_parameters, mirrors the signature AdaptiveDialog.builder pins
    Widget Function(BuildContext context, bool isFullscreen)? builder,
  }) {
    return AdaptiveDialog(
      fullscreenBreakpoint: fullscreenBreakpoint,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: padding,
      backgroundColor: backgroundColor,
      builder: builder ?? (context, isFullscreen) => const SizedBox.expand(key: _contentKey),
    );
  }

  Widget build({ThemeData? theme, AdaptiveDialog? child}) => MaterialApp(theme: theme, home: child ?? dialog());

  Finder inDialog(Finder matching) => find.descendant(of: find.byType(AdaptiveDialog), matching: matching);

  group('layout mode', () {
    testWidgets('is fullscreen below the breakpoint', (tester) async {
      late bool received;
      await pump(
        tester,
        build(
          child: dialog(
            builder: (context, isFullscreen) {
              received = isFullscreen;
              return const SizedBox.expand(key: _contentKey);
            },
          ),
        ),
        size: const Size(599, 800),
      );

      expect(received, isTrue);
      expect(tester.getSize(find.byKey(_contentKey)), const Size(599, 800));
      expect(tester.getTopLeft(find.byKey(_contentKey)), Offset.zero);
      expect(inDialog(find.byType(ClipRRect)), findsNothing);
      expect(inDialog(find.byType(Center)), findsNothing);
    });

    testWidgets('is a card exactly at the breakpoint', (tester) async {
      late bool received;
      await pump(
        tester,
        build(
          child: dialog(
            builder: (context, isFullscreen) {
              received = isFullscreen;
              return const SizedBox.expand(key: _contentKey);
            },
          ),
        ),
        size: const Size(600, 700),
      );

      expect(received, isFalse);
      expect(inDialog(find.byType(ClipRRect)), findsOneWidget);
      // The viewport minus the default padding of 16 on each side.
      expect(tester.getSize(find.byKey(_contentKey)), const Size(568, 668));
    });

    testWidgets('honours a custom fullscreenBreakpoint', (tester) async {
      await pump(tester, build(child: dialog(fullscreenBreakpoint: 300)), size: const Size(400, 600));
      expect(inDialog(find.byType(ClipRRect)), findsOneWidget);

      await pump(tester, build(child: dialog(fullscreenBreakpoint: 500)), size: const Size(400, 600));
      expect(inDialog(find.byType(ClipRRect)), findsNothing);
    });

    testWidgets('measures the incoming constraints, not the screen', (tester) async {
      late bool received;
      await pump(
        tester,
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              height: 500,
              child: dialog(
                builder: (context, isFullscreen) {
                  received = isFullscreen;
                  return const SizedBox.expand(key: _contentKey);
                },
              ),
            ),
          ),
        ),
        size: const Size(1200, 800),
      );

      expect(received, isTrue);
      expect(tester.getSize(find.byKey(_contentKey)), const Size(400, 500));
    });

    testWidgets('clamps the card to maxWidth/maxHeight, shrinks it by padding and centers it', (tester) async {
      await pump(
        tester,
        build(child: dialog(maxWidth: 500, maxHeight: 400, padding: const EdgeInsets.all(10))),
        size: const Size(1000, 800),
      );

      expect(tester.getSize(find.byKey(_contentKey)), const Size(480, 380));
      expect(tester.getCenter(find.byKey(_contentKey)), const Offset(500, 400));
    });
  });

  group('mode scope', () {
    testWidgets('isFullscreenOf agrees with the builder flag in both modes', (tester) async {
      late bool fromBuilder, fromScope;
      Widget widget() => build(
        child: dialog(
          builder: (context, isFullscreen) {
            fromBuilder = isFullscreen;
            return Builder(
              builder: (context) {
                fromScope = AdaptiveDialog.isFullscreenOf(context);
                return const SizedBox.expand(key: _contentKey);
              },
            );
          },
        ),
      );

      await pump(tester, widget(), size: const Size(400, 600));
      expect(fromBuilder, isTrue);
      expect(fromScope, isTrue);

      await pump(tester, widget(), size: const Size(900, 600));
      expect(fromBuilder, isFalse);
      expect(fromScope, isFalse);
    });

    testWidgets('the builder context itself can read the scope', (tester) async {
      late bool fromBuilderContext;
      await pump(
        tester,
        build(
          child: dialog(
            builder: (context, isFullscreen) {
              fromBuilderContext = AdaptiveDialog.isFullscreenOf(context);
              return const SizedBox.expand(key: _contentKey);
            },
          ),
        ),
        size: const Size(400, 600),
      );

      expect(fromBuilderContext, isTrue);
    });

    testWidgets('maybeIsFullscreenOf returns null outside a dialog', (tester) async {
      late bool? value;
      await pump(
        tester,
        MaterialApp(
          home: Builder(
            builder: (context) {
              value = AdaptiveDialog.maybeIsFullscreenOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(value, isNull);
    });

    testWidgets('isFullscreenOf asserts outside a dialog', (tester) async {
      await pump(
        tester,
        MaterialApp(
          home: Builder(
            builder: (context) {
              AdaptiveDialog.isFullscreenOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(tester.takeException(), isAssertionError);
    });
  });

  group('background color', () {
    Color cardColorOf(WidgetTester tester) => tester.widget<Material>(inDialog(find.byType(Material)).first).color!;

    Color fullscreenColorOf(WidgetTester tester) =>
        tester.widget<ColoredBox>(inDialog(find.byType(ColoredBox)).first).color;

    testWidgets('an explicit backgroundColor wins, in both modes', (tester) async {
      const color = Color(0xFF112233);

      await pump(
        tester,
        build(child: dialog(backgroundColor: color)),
        size: const Size(900, 600),
      );
      expect(cardColorOf(tester), color);

      await pump(
        tester,
        build(child: dialog(backgroundColor: color)),
        size: const Size(400, 600),
      );
      expect(fullscreenColorOf(tester), color);
    });

    testWidgets('falls back to the ambient DialogTheme', (tester) async {
      const color = Color(0xFF445566);
      final theme = ThemeData(dialogTheme: const DialogThemeData(backgroundColor: color));

      await pump(tester, build(theme: theme), size: const Size(900, 600));
      expect(cardColorOf(tester), color);

      await pump(tester, build(theme: theme), size: const Size(400, 600));
      expect(fullscreenColorOf(tester), color);
    });

    testWidgets('falls back to colorScheme.surface when the theme says nothing', (tester) async {
      final theme = ThemeData(colorScheme: const ColorScheme.dark());

      await pump(tester, build(theme: theme), size: const Size(900, 600));
      expect(cardColorOf(tester), theme.colorScheme.surface);
    });
  });

  group('show', () {
    Widget opener({bool dismissible = true, double barrierBlur = 0, VoidCallback? onResult}) {
      return MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              await AdaptiveDialog.show<String>(
                context,
                dialog(
                  builder: (context, isFullscreen) => Center(
                    child: TextButton(
                      key: _contentKey,
                      onPressed: () => Navigator.of(context).pop('popped'),
                      child: const Text('close'),
                    ),
                  ),
                ),
                dismissible: dismissible,
                barrierBlur: barrierBlur,
              );
              onResult?.call();
            },
            child: const Text(_openText),
          ),
        ),
      );
    }

    testWidgets('renders the dialog with no BackdropFilter when barrierBlur is 0', (tester) async {
      await pump(tester, opener());
      await tester.tap(find.text(_openText));
      await tester.pumpAndSettle();

      expect(find.byKey(_contentKey), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('stacks a non-interactive blurred scrim under the dialog when barrierBlur is set', (tester) async {
      await pump(tester, opener(barrierBlur: 6));
      await tester.tap(find.text(_openText));
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.ancestor(of: find.byType(BackdropFilter), matching: find.byType(IgnorePointer)), findsWidgets);
      expect(find.byKey(_contentKey), findsOneWidget);
    });

    testWidgets('pops on a barrier tap when dismissible', (tester) async {
      await pump(tester, opener(), size: const Size(900, 600));
      await tester.tap(find.text(_openText));
      await tester.pumpAndSettle();
      expect(find.byKey(_contentKey), findsOneWidget);

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(find.byKey(_contentKey), findsNothing);
    });

    testWidgets('stays open on a barrier tap when not dismissible', (tester) async {
      await pump(tester, opener(dismissible: false), size: const Size(900, 600));
      await tester.tap(find.text(_openText));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(find.byKey(_contentKey), findsOneWidget);
    });

    testWidgets('keeps the barrier tappable through the blur layer', (tester) async {
      await pump(tester, opener(barrierBlur: 6), size: const Size(900, 600));
      await tester.tap(find.text(_openText));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(find.byKey(_contentKey), findsNothing);
    });

    testWidgets('completes with the value the dialog was popped with', (tester) async {
      late String? result;
      await pump(
        tester,
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await AdaptiveDialog.show<String>(
                  context,
                  dialog(
                    builder: (context, isFullscreen) => Center(
                      child: TextButton(
                        key: _contentKey,
                        onPressed: () => Navigator.of(context).pop('popped'),
                        child: const Text('close'),
                      ),
                    ),
                  ),
                );
              },
              child: const Text(_openText),
            ),
          ),
        ),
      );

      await tester.tap(find.text(_openText));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_contentKey));
      await tester.pumpAndSettle();

      expect(result, 'popped');
    });
  });
}
