import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MyHomePage());
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final lifecycleState = useAppLifecycleState(
      onPaused: () => debugPrint("Paused"),
      onResumed: () => debugPrint("Resumed"),
      onHidden: () => debugPrint("Hidden"),
      onInactive: () => debugPrint("Inactive"),
    );

    useEffect(() {
      debugPrint("Lifecycle state: $lifecycleState");
    }, [lifecycleState]);

    return const Text("App");
  }
}
