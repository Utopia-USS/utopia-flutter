import 'dart:ui_web';

import 'package:cross_file/cross_file.dart';
import 'package:utopia_save_file/src/impl/impl.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';
import 'package:utopia_save_file/src/util/byte_stream_extensions.dart';
import 'package:web/web.dart';

typedef SaveFileTargetImpl = SaveFileWebImpl;

class SaveFileWebImpl implements SaveFileImpl {
  static const instance = SaveFileWebImpl._();

  const SaveFileWebImpl._();

  @override
  Future<bool> fromFile(XFile file, SaveFileMetadata metadata) async => fromUrl(file.path, metadata);

  @override
  Future<bool> fromUrl(String url, SaveFileMetadata metadata) async {
    HTMLAnchorElement()
      ..href = url
      ..download = metadata.name
      ..click();
    return true;
  }

  @override
  Future<bool> fromAsset(String key, SaveFileMetadata metadata) => fromUrl(assetManager.getAssetUrl(key), metadata);

  @override
  Future<bool> fromBytes(List<int> bytes, SaveFileMetadata metadata) async =>
      fromUrl(Uri.dataFromBytes(bytes, mimeType: metadata.mime).toString(), metadata);

  @override
  Future<bool> fromByteStream(Stream<List<int>> stream, SaveFileMetadata metadata) async =>
      fromBytes(await stream.toBytes(), metadata);
}
