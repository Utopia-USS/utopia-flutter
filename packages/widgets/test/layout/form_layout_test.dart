import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _backgroundColor = Color(0xFF123456);
const _bottomKey = ValueKey('bottom');
const _contentKey = ValueKey('content');
const _viewport = Size(400, 600);
const _bottomHeight = 60.0;
const _contentHeight = 2000.0;

void main() {
  void setUpViewport(WidgetTester tester) {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget wrap(Widget child) => Directionality(textDirection: TextDirection.ltr, child: child);

  double targetOpacity(WidgetTester tester) => tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  group('constructors', () {
    testWidgets('the deprecated default constructor wraps the content in a scroll view', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(
        wrap(
          // ignore: deprecated_member_use_from_same_package
          FormLayout(
            backgroundColor: _backgroundColor,
            content: const SizedBox(key: _contentKey, height: _contentHeight),
            bottom: const SizedBox(key: _bottomKey, height: _bottomHeight),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byKey(_contentKey), findsOneWidget);
      expect(find.byKey(_bottomKey), findsOneWidget);
    });

    testWidgets('simple wraps the content in a scroll view', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(
        wrap(
          FormLayout.simple(
            backgroundColor: _backgroundColor,
            content: const SizedBox(key: _contentKey, height: _contentHeight),
            bottom: const SizedBox(key: _bottomKey, height: _bottomHeight),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.getSize(find.byKey(_contentKey)).height, _contentHeight);
    });

    testWidgets('raw does not wrap the content in a scroll view', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(
        wrap(
          FormLayout.raw(
            backgroundColor: _backgroundColor,
            content: ListView(
              children: const [SizedBox(key: _contentKey, height: _contentHeight)],
            ),
            bottom: const SizedBox(key: _bottomKey, height: _bottomHeight),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('puts the bottom at the viewport bottom and lets the content take the rest', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(
        wrap(
          FormLayout.simple(
            backgroundColor: _backgroundColor,
            content: const SizedBox(key: _contentKey, height: _contentHeight),
            bottom: const SizedBox(key: _bottomKey, height: _bottomHeight),
          ),
        ),
      );

      expect(tester.getTopLeft(find.byKey(_bottomKey)).dy, _viewport.height - _bottomHeight);
      expect(tester.getSize(find.byType(SingleChildScrollView)).height, _viewport.height - _bottomHeight);
    });

    testWidgets('renders the fade bar with the configured height at the bottom of the content', (tester) async {
      setUpViewport(tester);

      await tester.pumpWidget(
        wrap(
          FormLayout.simple(
            backgroundColor: _backgroundColor,
            fadeBarHeight: 24,
            content: const SizedBox(key: _contentKey, height: _contentHeight),
            bottom: const SizedBox(key: _bottomKey, height: _bottomHeight),
          ),
        ),
      );

      final fadeBar = find.byType(AnimatedOpacity);
      expect(tester.getSize(fadeBar).height, 24);
      expect(tester.getBottomLeft(fadeBar).dy, _viewport.height - _bottomHeight);
    });
  });

  group('fade bar visibility', () {
    late ScrollController controller;

    setUp(() => controller = ScrollController());
    tearDown(() => controller.dispose());

    Future<void> pumpRaw(WidgetTester tester, {double fadeBarHeight = 16}) async {
      setUpViewport(tester);
      await tester.pumpWidget(
        wrap(
          FormLayout.raw(
            backgroundColor: _backgroundColor,
            fadeBarHeight: fadeBarHeight,
            content: SingleChildScrollView(
              controller: controller,
              child: const SizedBox(key: _contentKey, height: _contentHeight),
            ),
            bottom: const SizedBox(key: _bottomKey, height: _bottomHeight),
          ),
        ),
      );
    }

    testWidgets('is visible initially', (tester) async {
      await pumpRaw(tester);

      expect(targetOpacity(tester), 1);
    });

    testWidgets('fades out once scrolled within fadeBarHeight of the max scroll extent', (tester) async {
      await pumpRaw(tester);
      final maxScrollExtent = controller.position.maxScrollExtent;
      expect(maxScrollExtent, _contentHeight - (_viewport.height - _bottomHeight));

      controller.jumpTo(maxScrollExtent - 16);
      await tester.pumpAndSettle();

      expect(targetOpacity(tester), 0);
    });

    testWidgets('stays visible just above the fade threshold', (tester) async {
      await pumpRaw(tester);

      controller.jumpTo(controller.position.maxScrollExtent - 17);
      await tester.pumpAndSettle();

      expect(targetOpacity(tester), 1);
    });

    testWidgets('is hidden at the very end of the scroll', (tester) async {
      await pumpRaw(tester);

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(targetOpacity(tester), 0);
    });

    testWidgets('comes back when scrolling up again', (tester) async {
      await pumpRaw(tester);

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(targetOpacity(tester), 0);

      controller.jumpTo(0);
      await tester.pumpAndSettle();

      expect(targetOpacity(tester), 1);
    });

    testWidgets('honours a custom fadeBarHeight as the threshold', (tester) async {
      await pumpRaw(tester, fadeBarHeight: 100);

      controller.jumpTo(controller.position.maxScrollExtent - 101);
      await tester.pumpAndSettle();
      expect(targetOpacity(tester), 1);

      controller.jumpTo(controller.position.maxScrollExtent - 100);
      await tester.pumpAndSettle();
      expect(targetOpacity(tester), 0);
    });

    testWidgets('does not intercept pointer events', (tester) async {
      await pumpRaw(tester);

      expect(find.ancestor(of: find.byType(AnimatedOpacity), matching: find.byType(IgnorePointer)), findsOneWidget);
    });
  });
}
