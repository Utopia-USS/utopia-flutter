import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_riverpod/utopia_hooks_riverpod.dart';

final counterProvider = StateProvider((ref) => 0);

void main() {
  group('HookConsumer', () {
    testWidgets('builder receives HookConsumerRef with watch/read and hooks work together', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumer(
              builder: (context, ref) {
                final state = useState(0);
                final value = ref.watch(counterProvider);

                return GestureDetector(
                  onTap: () {
                    state.value++;
                    ref.read(counterProvider.notifier).state++;
                  },
                  child: Text('${state.value} - $value'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('0 - 0'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.text('1 - 1'), findsOneWidget);
    });

    testWidgets('useHookRef returns HookConsumerRef', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumer(
              builder: (context, ref) {
                final hookRef = useHookRef();
                expect(hookRef, isA<HookConsumerRef>());
                return const Text('ok');
              },
            ),
          ),
        ),
      );

      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('useHookConsumerRef exposes widgetRef for direct WidgetRef access', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumer(
              builder: (context, ref) {
                final consumerRef = useHookConsumerRef();
                final valueViaRef = ref.watch(counterProvider);
                final valueViaWidgetRef = consumerRef.widgetRef.watch(counterProvider);
                expect(valueViaRef, equals(valueViaWidgetRef));
                return Text('$valueViaRef');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('useRefWatch triggers rebuild when provider changes', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: HookConsumer(
              builder: (context, ref) {
                final value = useRefWatch(counterProvider);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$value'),
                    GestureDetector(
                      onTap: () => ref.read(counterProvider.notifier).state++,
                      child: const Text('increment'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.text('increment'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('HookConsumerWidget subclass', () {
    testWidgets('build receives HookConsumerRef and can use ref and hooks', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: _CustomHookConsumer(
              child: Text('child'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });
}

class _CustomHookConsumer extends HookConsumerWidget {
  const _CustomHookConsumer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, HookConsumerRef ref) {
    final count = ref.watch(counterProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count'),
        GestureDetector(
          onTap: () => ref.read(counterProvider.notifier).state++,
          child: child,
        ),
      ],
    );
  }
}
