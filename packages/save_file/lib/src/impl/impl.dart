import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';

import 'native_impl.dart' if (dart.library.js) 'web_impl.dart';

abstract interface class SaveFileImpl {
  static final instance = SaveFileTargetImpl.instance;

  Future<bool> fromFile(XFile file, SaveFileMetadata metadata);

  Future<bool> fromUrl(String url, SaveFileMetadata metadata);

  Future<bool> fromBytes(List<int> bytes, SaveFileMetadata metadata);

  Future<bool> fromByteStream(Stream<List<int>> stream, SaveFileMetadata metadata);
}
