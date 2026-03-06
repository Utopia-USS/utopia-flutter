import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_riverpod/utopia_hooks_riverpod.dart';

final provider = StateProvider((ref) => 0);

class GlobalState {
  final int value;
  final void Function() onTap;

  const GlobalState({
    required this.value,
    required this.onTap,
  });
}

GlobalState useGlobalState() {
  final state = useState(0);
  return GlobalState(value: state.value + useRefWatch(provider), onTap: () => state.value++);
}

int useSum() => useRefWatch(provider) + useRefWatch(provider);

void main() {
  group('HookConsumerProviderContainerWidget', () {
    testWidgets('hook providers and Riverpod provider work together', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumerProviderContainerWidget(
              const {GlobalState: useGlobalState},
              child: HookConsumer(
                builder: (context, ref) {
                  final a = ref.watch(provider);
                  final b = useProvided<GlobalState>();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$a - ${b.value}'),
                      GestureDetector(
                        onTap: () => ref.read(provider.notifier).state++,
                        child: const Text('inc provider only'),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(provider.notifier).state++;
                          b.onTap();
                        },
                        child: const Text('inc both'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('0 - 0'), findsOneWidget);

      await tester.tap(find.text('inc both'));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.idle();

      expect(find.text('1 - 2'), findsOneWidget);

      // Updating only the Riverpod provider must refresh hook providers that use useRefWatch(provider).
      await tester.tap(find.text('inc provider only'));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.idle();

      expect(find.text('2 - 3'), findsOneWidget);
    });

    testWidgets('builder receives HookConsumerRef with widgetRef; useHookRef works', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumerProviderContainerWidget(
              const {GlobalState: useGlobalState},
              child: HookConsumer(
                builder: (context, ref) {
                  // In the builder we get HookConsumerRef (from HookConsumer's context).
                  expect(ref, isA<HookConsumerRef>());
                  expect(ref.widgetRef, isA<WidgetRef>());
                  final hookRef = useHookRef();
                  expect(hookRef, isA<HookConsumerRef>());
                  return const Text('ok');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('useRefWatch in hook provider causes container refresh when provider changes', (tester) async {
      // GlobalState uses useRefWatch(provider). When we only increment the Riverpod provider,
      // the hook container must refresh so GlobalState is recomputed with the new value.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumerProviderContainerWidget(
              const {GlobalState: useGlobalState},
              child: HookConsumer(
                builder: (context, ref) {
                  final b = useProvided<GlobalState>();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${b.value}'),
                      GestureDetector(
                        onTap: () => ref.read(provider.notifier).state++,
                        child: const Text('inc'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.text('inc'));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.idle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('multiple hook providers depending on Riverpod provider all refresh', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumerProviderContainerWidget(
              const {GlobalState: useGlobalState, int: useSum},
              child: HookConsumer(
                builder: (context, ref) {
                  final b = useProvided<GlobalState>();
                  final s = useProvided<int>(); // useSum() => provider*2
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${b.value}-$s'),
                      GestureDetector(
                        onTap: () => ref.read(provider.notifier).state++,
                        child: const Text('inc'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('0-0'), findsOneWidget);

      await tester.tap(find.text('inc'));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.idle();

      expect(find.text('1-2'), findsOneWidget);
    });
  });
}
