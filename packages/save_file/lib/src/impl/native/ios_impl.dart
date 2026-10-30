import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:utopia_save_file/src/impl/impl.native.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';

/// Writes the file to a private temporary directory and presents the system share sheet with it, so the user picks
/// the destination ("Save to Files", AirDrop, Mail, ...). The temporary copy is deleted once the sheet is dismissed.
class SaveFileIosImpl implements SaveFileNativeImpl {
  static const _channel = MethodChannel('utopia_save_file');

  static const instance = SaveFileIosImpl._();

  const SaveFileIosImpl._();

  @override
  Future<bool> fromFile(XFile file, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) async =>
      _share(file.openRead(), metadata, sharePositionOrigin);

  @override
  Future<bool> fromUrl(String url, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) async =>
      _share(await _fetch(url), metadata, sharePositionOrigin);

  @override
  Future<bool> fromBytes(List<int> bytes, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) async =>
      _share(Stream.value(bytes), metadata, sharePositionOrigin);

  @override
  Future<bool> fromByteStream(
    Stream<List<int>> stream,
    SaveFileMetadata metadata, {
    Rect? sharePositionOrigin,
  }) async =>
      _share(stream, metadata, sharePositionOrigin);

  @override
  Future<bool> fromAsset(String name, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) async =>
      _share(Stream.value((await rootBundle.load(name)).buffer.asUint8List()), metadata, sharePositionOrigin);

  Future<Stream<List<int>>> _fetch(String url) async {
    final request = await HttpClient().getUrl(Uri.parse(url));
    return request.close();
  }

  static Future<bool> _share(Stream<List<int>> stream, SaveFileMetadata metadata, Rect? origin) async {
    final directory = await Directory.systemTemp.createTemp('utopia_save_file_');
    try {
      final file = File(path.join(directory.path, metadata.name));
      final sink = file.openWrite();
      try {
        // Cast needed because of Dart type system issue: IOSink is not a subtype of StreamConsumer<Uint8List>
        await stream.cast<List<int>>().pipe(sink);
      } finally {
        await sink.close();
      }
      final result = await _channel.invokeMethod<bool>('share', {
        'path': file.path,
        if (origin != null) 'origin': [origin.left, origin.top, origin.width, origin.height],
      });
      return result!;
    } finally {
      await directory.delete(recursive: true);
    }
  }
}
