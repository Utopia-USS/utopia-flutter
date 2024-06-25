import 'dart:ui';

import 'package:utopia_localization_annotation/utopia_localization_annotation.dart';

extension LocalizationMapLocaleExtensions<T> on UtopiaLocalizationData<T> {
  Set<Locale> get supportedLocales => map.keys.map(localeFromLanguageTag).toSet();

  T? operator [](Locale locale) => map[locale.toLanguageTag()];
}

Locale localeFromLanguageTag(String languageTag) {
  final parts = languageTag.split('-');
  return Locale.fromSubtags(
    languageCode: parts[0],
    scriptCode: parts.length == 3 ? parts[1] : null,
    countryCode: parts.length > 1 ? parts.last : null,
  );
}
