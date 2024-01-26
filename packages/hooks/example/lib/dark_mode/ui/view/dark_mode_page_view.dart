import 'package:flutter/material.dart';
import 'package:utopia_hooks_example/dark_mode/ui/state/dark_mode_page_state.dart';
import 'package:utopia_hooks_example/dark_mode/util/context_extension.dart';

class DarkModePageView extends StatelessWidget {
  final DarkModePageState state;

  const DarkModePageView(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: context.colors.field,
        title: Text("Flutter demo dark mode", style: context.texts.body),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.onModeChanged,
        backgroundColor: context.colors.field,
        tooltip: 'Change mode',
        child: Icon(
          state.darkMode ? Icons.nightlight_outlined : Icons.sunny,
          color: context.colors.icon,
        ),
      ),
    );
  }
}
