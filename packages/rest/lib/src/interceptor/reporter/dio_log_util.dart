import 'dart:convert';

import 'package:dio/dio.dart';

class DioLogUtil {
  const DioLogUtil._();

  static String buildResponseLog(Response response, {bool sanitize = false}) {
    late final prettyData = _tryPrettyPrint(response.data);
    return [
      'HTTP response',
      '${response.requestOptions.method} ${response.requestOptions.uri}',
      '<-- ${response.statusCode}',
      if (!sanitize)
        for (final header in response.headers.map.entries) '${header.key}: ${header.value}',
      if (!sanitize && prettyData != null) prettyData,
    ].join('\n');
  }

  static String buildRequestLog(RequestOptions options, {bool sanitize = false}) {
    late final prettyData = _tryPrettyPrint(options.data);
    return [
      'HTTP request',
      '${options.method} ${options.uri}',
      if (!sanitize)
        for (final header in options.headers.entries) '${header.key}: ${header.value}',
      if (!sanitize && prettyData != null) prettyData,
    ].join('\n');
  }

  static String? _tryPrettyPrint(dynamic data) {
    if (data.runtimeType == _typeOf<void>()) return null;
    if (data is List<int>) return 'Byte data, length=${data.length} bytes';
    if (data is FormData) return _printFormData(data);
    return _tryPrintJsonData(data);
  }

  static String _printFormData(FormData data) {
    final fields = data.fields.map((entry) => '${entry.key}: ${entry.value}');
    final files = data.files
        .map((entry) => '${entry.key}: File, name=${entry.value.filename ?? 'unknown'}, length=${entry.value.length}');
    return fields.followedBy(files).join('\n');
  }

  static String? _tryPrintJsonData(dynamic data) {
    final encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(jsonDecode(data));
    } catch(_) {
      try {
        return encoder.convert(data);
      } catch(_) {
        return null;
      }
    }
  }

  static Type _typeOf<T>() => T;
}
