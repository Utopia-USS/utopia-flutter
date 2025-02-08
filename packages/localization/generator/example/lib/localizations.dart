@UtopiaLocalization('1mcv7Zzg1HI35gz_IhltBPnkZkSXgxw9IwyAQfAgasck', '0', 20, fallbackLocale: 'en')
library;

import 'package:utopia_localization_annotation/utopia_localization_annotation.dart';

part 'localizations.g.dart';

enum Plural {
  zero,
  one,
  multiple,
}

enum Gender {
  male,
  female,
}

extension PluralExtension on int {
  Plural plural() {
    if (this == 0) return Plural.zero;
    if (this == 1) return Plural.one;
    return Plural.multiple;
  }
}
