import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/dark_mode/theme/app_colors.dart';
import 'package:utopia_hooks_example/dark_mode/theme/app_texts.dart';

class ThemeState {
  final bool darkMode;
  final AppColors colors;
  final AppTexts texts;
  final void Function() changeType;

  const ThemeState({
    required this.colors,
    required this.darkMode,
    required this.texts,
    required this.changeType,
  });
}

ThemeState useThemeState() {
  final darkModeState = useState<bool>(false);

  final colors = useMemoized(() => darkModeState.value ? AppColors.light : AppColors.dark, [darkModeState.value]);
  final texts = useMemoized(() => AppTexts(colors: colors), [colors]);

  return ThemeState(
    darkMode: darkModeState.value,
    changeType: darkModeState.toggle,
    colors: colors,
    texts: texts,
  );
}
