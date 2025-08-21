import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_localization_annotation/utopia_localization_annotation.dart';
import 'package:utopia_localization_utils/src/locale_utils.dart';

class UtopiaLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  final UtopiaLocalizationData<T> data;

  const UtopiaLocalizationsDelegate(this.data);

  @override
  bool isSupported(Locale locale) => data.supportedLocales.contains(locale);

  @override
  Future<T> load(Locale locale) => SynchronousFuture(data[locale] as T);

  @override
  bool shouldReload(UtopiaLocalizationsDelegate<T> old) => old.data != data;
}
