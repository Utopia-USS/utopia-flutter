import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/dark_mode/global_state/theme_state.dart';
import 'package:utopia_hooks_example/dark_mode/theme/app_colors.dart';
import 'package:utopia_hooks_example/dark_mode/theme/app_texts.dart';

extension BuildContextExtension on BuildContext {
  ThemeState get theme => get<ThemeState>();

  AppColors get colors => theme.colors;

  AppTexts get texts => theme.texts;
}
