import 'package:flutter/widgets.dart';

extension BuildContextLocalizationsExtensions on BuildContext {
  T localizations<T>() => Localizations.of(this, T)!;
}
