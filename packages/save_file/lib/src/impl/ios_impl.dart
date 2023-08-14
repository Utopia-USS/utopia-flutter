import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:utopia_save_file/src/impl/native_impl.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';
import 'package:utopia_save_file/src/util/extension_helper.dart';

class SaveFileIosImpl implements SaveFileNativeImpl {
  static const instance = SaveFileIosImpl._();

  const SaveFileIosImpl._();

  @override
  Future<bool> fromFile(XFile file, SaveFileMetadata metadata) async => _save(file.openRead(), metadata);

  @override
  Future<bool> fromUrl(String url, SaveFileMetadata metadata) async => _save(await _fetch(url), metadata);

  @override
  Future<bool> fromBytes(List<int> bytes, SaveFileMetadata metadata) async => _save(Stream.value(bytes), metadata);

  @override
  Future<bool> fromByteStream(Stream<List<int>> stream, SaveFileMetadata metadata) async => _save(stream, metadata);

  Future<Stream<List<int>>> _fetch(String url) async {
    final request = await HttpClient().getUrl(Uri.parse(url));
    return request.close();
  }

  static Future<bool> _save(Stream<List<int>> stream, SaveFileMetadata metadata) async {
    final file = await _buildFile(metadata.name);
    final sink = file.openWrite();
    try {
      await stream.pipe(sink);
      return true;
    } finally {
      await sink.close();
    }
  }

  static Future<File> _buildFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    var file = File(path.join(directory.path, name));
    var counter = 0;
    while (file.existsSync()) {
      counter++;
      file = File(path.join(directory.path, ExtensionHelper.addCounter(name, counter)));
    }
    return file;
  }
}
