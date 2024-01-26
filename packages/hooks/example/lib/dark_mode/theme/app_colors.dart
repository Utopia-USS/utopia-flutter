import 'package:flutter/material.dart';

class AppColors {
  final Color text;
  final Color canvas;
  final Color field;
  final Color icon;

  const AppColors._({
    required this.text,
    required this.canvas,
    required this.icon,
    required this.field,
  });

  static AppColors light = AppColors._(
    text: const Color(0xFF060542),
    canvas: const Color(0xFFE2EAF6),
    field: Colors.grey[200]!,
    icon: const Color(0xFF04266C),
  );

  static AppColors dark = AppColors._(
    text: const Color(0xFFFFFFFF),
    canvas: const Color(0xFF00030E),
    field: Colors.grey[900]!,
    icon: Colors.yellow,
  );
}
