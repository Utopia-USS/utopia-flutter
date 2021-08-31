import 'package:intl/intl.dart';

extension DateFormatExtensions on DateFormat {
  DateTime? tryParseStrict(String value) {
    try {
      return parseStrict(value);
    } on FormatException {
      return null;
    }
  }
}