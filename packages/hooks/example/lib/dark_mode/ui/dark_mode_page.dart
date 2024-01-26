import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/dark_mode/ui/state/dark_mode_page_state.dart';
import 'package:utopia_hooks_example/dark_mode/ui/view/dark_mode_page_view.dart';

class DarkModePage extends StatelessWidget {
  const DarkModePage();

  @override
  Widget build(BuildContext context) {
    return const HookCoordinator(
      use: useDarkModePageState,
      builder: DarkModePageView.new,
    );
  }
}
