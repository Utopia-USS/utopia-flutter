import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fieldState = useState("");

    final computedState = useAutoComputedState<String>(
      debounceDuration: const Duration(seconds: 1),
      keys: [fieldState.value],
      () async {
        debugPrint("Computing at ${DateTime.now().toIso8601String()}");
        await Future<void>.delayed(const Duration(seconds: 5));
        return fieldState.value + DateTime.now().toIso8601String();
      },
    );

    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: Column(
          children: [
            StatelessTextEditingControllerWrapper(
              text: fieldState,
              builder: (controller) => TextField(controller: controller),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: RefreshableComputedStateWrapper<String>(
                  state: computedState,
                  inProgressBuilder: (context) => const Text("InProgress"),
                  failedBuilder: (context) => const Text("Failed"),
                  builder: (context, value) => Text(value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
