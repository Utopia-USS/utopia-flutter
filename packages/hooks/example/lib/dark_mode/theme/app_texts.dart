import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTexts {
  final AppColors colors;

  const AppTexts({required this.colors});

  TextStyle get _base => TextStyle(fontFamily: "Roboto", color: colors.text);

  TextStyle get body => _base.copyWith(fontWeight: FontWeight.w500, fontSize: 12);
}
