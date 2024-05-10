import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_riverpod/src/hook_consumer_provider_container_widget.dart';
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

void main() {
  testWidgets('HookConsumerProviderContainerWidget', (tester) async {
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

                return GestureDetector(
                  onTap: () {
                    ref.read(provider.notifier).state++;
                    b.onTap();
                  },
                  child: Text('$a - ${b.value}'),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('0 - 0'), findsOneWidget);

    await tester.tap(find.byType(GestureDetector));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.idle();


    expect(find.text('1 - 2'), findsOneWidget);
  });
}
