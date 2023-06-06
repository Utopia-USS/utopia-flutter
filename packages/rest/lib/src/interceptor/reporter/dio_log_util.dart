import 'dart:convert';

import 'package:dio/dio.dart';

class DioLogUtil {
  const DioLogUtil._();

  static String buildResponseLog(Response<dynamic> response, {bool sanitize = false}) {
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

  static String? _tryPrettyPrint(Object? data) {
    if (_isEmptyData(data)) return null;
    if (data is List<int>) return 'Byte data, length=${data.length} bytes';
    if (data is FormData) return _printFormData(data);
    return _tryPrintJsonData(data);
  }

  static bool _isEmptyData(Object? data) {
    return data.runtimeType == _typeOf<void>() ||
        (data is List && data.isEmpty) ||
        (data is Map && data.isEmpty) ||
        (data is String && data.isEmpty);
  }

  static String _printFormData(FormData data) {
    final fields = data.fields.map((entry) => '${entry.key}: ${entry.value}');
    final files = data.files
        .map((entry) => '${entry.key}: File, name=${entry.value.filename ?? 'unknown'}, length=${entry.value.length}');
    return fields.followedBy(files).join('\n');
  }

  static String? _tryPrintJsonData(Object? data) {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(jsonDecode(data! as String));
    } catch (_) {
      try {
        return encoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
  }

  static Type _typeOf<T>() => T;
}
