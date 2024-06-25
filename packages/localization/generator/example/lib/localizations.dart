@UtopiaLocalization('1AcjI1BjmQpjlnPUZ7aVLbrnVR98xtATnSjU4CExM9fs', '0', 16)
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
