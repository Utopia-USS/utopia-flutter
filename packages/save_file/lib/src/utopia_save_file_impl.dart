import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:utopia_save_file/src/dto/save_file_from_bytes_dto.dart';
import 'package:utopia_save_file/src/dto/save_file_from_url_dto.dart';
import 'package:utopia_save_file/src/util/byte_stream_extensions.dart';

class UtopiaSaveFileImpl {
  static const MethodChannel _channel = MethodChannel('utopia_save_file');

  static Future<bool> fromUrl(String url, {String? name}) async {
    late final uri = Uri.parse(url);
    late final effectiveName = name ?? uri.pathSegments.last;
    if (Platform.isAndroid) {
      return await _fromUrlAndroid(url, effectiveName);
    }
    if (Platform.isIOS) {
      await _fromUriIos(uri, effectiveName);
      return true;
    }
    throw UnimplementedError('Unsupported platform for UtopiaSaveFile');
  }

  static Future<bool> fromByteStream(Stream<List<int>> stream, {required String name, required String mime}) async {
    if (Platform.isAndroid) {
      return await _fromByteStreamAndroid(stream, name, mime);
    }
    if (Platform.isIOS) {
      await _fromByteStreamIos(stream, name);
      return true;
    }
    throw UnimplementedError('Unsupported platform for UtopiaSaveFile');
  }

  static Future<bool> _fromUrlAndroid(String url, String effectiveName) async {
    final dto = SaveFileFromUrlDto(url: url, name: effectiveName);
    return await _channel.invokeMethod('saveFileFromUrl', dto.toJson());
  }

  static Future<bool> _fromByteStreamAndroid(Stream<List<int>> stream, String name, String mime) async {
    final dto = SaveFileFromBytesDto(bytes: await stream.toBytes(), name: name, mime: mime);
    return await _channel.invokeMethod('saveFileFromBytes', dto.toJson());
  }

  static Future<void> _fromUriIos(Uri uri, String effectiveName) async {
    // uses `dart:io` to avoid dependency on `http` or `dio` packages
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    await _fromByteStreamIos(response, effectiveName);
  }

  static Future<void> _fromByteStreamIos(Stream<List<int>> stream, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, name));
    final sink = file.openWrite();
    try {
      await stream.pipe(sink);
    } finally {
      await sink.close();
    }
  }
}
