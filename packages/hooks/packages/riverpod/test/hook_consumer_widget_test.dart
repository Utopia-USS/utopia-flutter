import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_riverpod/utopia_hooks_riverpod.dart';

final provider = StateProvider((ref) => 0);

void main() {
  testWidgets('HookConsumerWidget', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProviderScope(
          child: HookConsumer(
            builder: (context, ref) {
              final state = useState(0);
              final value = ref.watch(provider);

              return GestureDetector(
                onTap: () {
                  state.value++;
                  ref.read(provider.notifier).state++;
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
}
