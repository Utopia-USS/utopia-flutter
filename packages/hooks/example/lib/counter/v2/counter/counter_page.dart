import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/counter/v2/counter/state/counter_page_state.dart';
import 'package:utopia_hooks_example/counter/v2/counter/view/counter_page_view.dart';

class CounterPage extends StatelessWidget {
  const CounterPage();

  @override
  Widget build(BuildContext context) => const HookCoordinator(use: useCounterPageState, builder: CounterPageView.new);
}
