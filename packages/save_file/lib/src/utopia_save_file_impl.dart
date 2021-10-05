import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:utopia_save_file/src/save_file_from_url_dto.dart';

class UtopiaSaveFileImpl {
  static const MethodChannel _channel = MethodChannel('utopia_save_file');

  static Future<bool> fromUrl(String url, {String? name}) async {
    late final uri = Uri.parse(url);
    late final effectiveName = name ?? uri.pathSegments.last;
    if (Platform.isAndroid) {
      return await _saveAndroid(url, effectiveName);
    }
    if (Platform.isIOS) {
      await _saveIos(uri, effectiveName);
      return true;
    }
    throw UnimplementedError('Unsupported platform for UtopiaSaveFile');
  }

  static Future<bool> _saveAndroid(String url, String effectiveName) async {
    final dto = SaveFileFromUrlDto(url: url, name: effectiveName);
    return await _channel.invokeMethod('saveFileFromUrl', dto.toJson());
  }

  static Future<void> _saveIos(Uri uri, String effectiveName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, effectiveName));
    // uses `dart:io` to avoid dependency on `http` or `dio` packages
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    final sink = file.openWrite();
    try {
      await response.pipe(sink);
    } finally {
      await sink.close();
    }
  }
}