import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/dark_mode/global_state/theme_state.dart';
import 'package:utopia_hooks_example/dark_mode/ui/dark_mode_page.dart';

void main() => runApp(const DarkModeApp());

class DarkModeApp extends StatelessWidget {
  const DarkModeApp();

  @override
  Widget build(BuildContext context) {
    return const HookProviderContainerWidget(
      {ThemeState: useThemeState},
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: DarkModePage(),
      ),
    );
  }
}
