import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _childKey = ValueKey('child');
const _loaderKey = ValueKey('loader');
const _overlayStyle = SystemUiOverlayStyle(statusBarColor: Color(0xFF00FF00));

void main() {
  Future<void> pump(WidgetTester tester, {required bool isLoaderVisible}) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: LoaderWrapperLayout(
        isLoaderVisible: isLoaderVisible,
        loaderUiOverlayStyle: _overlayStyle,
        loaderBuilder: (context) => const SizedBox(key: _loaderKey, width: 40, height: 40),
        child: const SizedBox(key: _childKey),
      ),
    ),
  );

  IgnorePointer ignorePointerOf(WidgetTester tester) => tester.widget<IgnorePointer>(
    find.descendant(of: find.byType(LoaderWrapperLayout), matching: find.byType(IgnorePointer)),
  );

  PopScope<dynamic> popScopeOf(WidgetTester tester) => tester.widget<PopScope<dynamic>>(
    find.descendant(of: find.byType(LoaderWrapperLayout), matching: find.byType(PopScope<dynamic>)),
  );

  testWidgets('always renders the child', (tester) async {
    await pump(tester, isLoaderVisible: false);
    expect(find.byKey(_childKey), findsOneWidget);

    await pump(tester, isLoaderVisible: true);
    expect(find.byKey(_childKey), findsOneWidget);
  });

  group('loader visible', () {
    testWidgets('renders the loader under a BlockSemantics', (tester) async {
      await pump(tester, isLoaderVisible: true);

      expect(find.byKey(_loaderKey), findsOneWidget);
      expect(find.descendant(of: find.byType(BlockSemantics), matching: find.byKey(_loaderKey)), findsOneWidget);
    });

    testWidgets('blocks pointer events on the child', (tester) async {
      await pump(tester, isLoaderVisible: true);

      expect(ignorePointerOf(tester).ignoring, isTrue);
      expect(find.descendant(of: find.byType(IgnorePointer), matching: find.byKey(_childKey)), findsOneWidget);
    });

    testWidgets('prevents popping', (tester) async {
      await pump(tester, isLoaderVisible: true);

      expect(popScopeOf(tester).canPop, isFalse);
    });

    testWidgets('applies the loader system ui overlay style', (tester) async {
      await pump(tester, isLoaderVisible: true);

      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );

      expect(region.value, _overlayStyle);
      expect(
        find.descendant(of: find.byType(AnnotatedRegion<SystemUiOverlayStyle>), matching: find.byKey(_loaderKey)),
        findsOneWidget,
      );
    });
  });

  group('loader hidden', () {
    testWidgets('does not render the loader', (tester) async {
      await pump(tester, isLoaderVisible: false);

      expect(find.byKey(_loaderKey), findsNothing);
      expect(find.byType(BlockSemantics), findsNothing);
      expect(find.byType(AnnotatedRegion<SystemUiOverlayStyle>), findsNothing);
    });

    testWidgets('lets pointer events through to the child', (tester) async {
      await pump(tester, isLoaderVisible: false);

      expect(ignorePointerOf(tester).ignoring, isFalse);
    });

    testWidgets('allows popping', (tester) async {
      await pump(tester, isLoaderVisible: false);

      expect(popScopeOf(tester).canPop, isTrue);
    });
  });

  testWidgets('expands the child to fill the available space', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pump(tester, isLoaderVisible: false);

    expect(tester.getSize(find.byKey(_childKey)), const Size(400, 600));
  });

  testWidgets('toggles the loader when isLoaderVisible changes', (tester) async {
    await pump(tester, isLoaderVisible: false);
    expect(find.byKey(_loaderKey), findsNothing);

    await pump(tester, isLoaderVisible: true);
    expect(find.byKey(_loaderKey), findsOneWidget);
    expect(popScopeOf(tester).canPop, isFalse);

    await pump(tester, isLoaderVisible: false);
    expect(find.byKey(_loaderKey), findsNothing);
    expect(popScopeOf(tester).canPop, isTrue);
  });
}
