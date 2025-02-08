export 'package:utopia_localization_template/utopia_localization_template.dart';

class UtopiaLocalization {
  final String docId;
  final String sheetId;
  final int version;
  final String className, fieldName;
  final bool jsonSerializers;
  final String? fallbackLocale;

  const UtopiaLocalization(
    this.docId,
    this.sheetId,
    this.version, {
    this.className = "AppLocalizationsData",
    this.fieldName = "appLocalizationsData",
    this.jsonSerializers = true,
    this.fallbackLocale,
  });
}

extension type const UtopiaLocalizationData<T>(Map<String, T> map) {
  factory UtopiaLocalizationData.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) =>
      UtopiaLocalizationData(json.map((key, value) => MapEntry(key, fromJsonT(value as Map<String, dynamic>))));
}
