import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/dark_mode/global_state/theme_state.dart';

class DarkModePageState {
  final bool darkMode;
  final void Function() onModeChanged;

  const DarkModePageState({
    required this.onModeChanged,
    required this.darkMode,
  });
}

DarkModePageState useDarkModePageState() {
  final themeState = useProvided<ThemeState>();

  return DarkModePageState(
    onModeChanged: themeState.changeType,
    darkMode: themeState.darkMode,
  );
}
