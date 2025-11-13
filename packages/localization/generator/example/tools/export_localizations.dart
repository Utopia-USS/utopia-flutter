import 'dart:convert';
import 'dart:io';

import 'package:utopia_localization_generator_example/localizations.dart';

void main() {
  stdout.write(jsonEncode(appLocalizationsData));
}
