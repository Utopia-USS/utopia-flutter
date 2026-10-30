import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:utopia_save_file/src/impl/impl.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';

typedef SaveFileTargetImpl = SaveFileStubImpl;

class SaveFileStubImpl implements SaveFileImpl {
  static const instance = SaveFileStubImpl._();

  const SaveFileStubImpl._();

  @override
  Future<bool> fromFile(XFile file, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) =>
      throw UnimplementedError();

  @override
  Future<bool> fromUrl(String url, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) =>
      throw UnimplementedError();

  @override
  Future<bool> fromAsset(String key, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) =>
      throw UnimplementedError();

  @override
  Future<bool> fromBytes(List<int> bytes, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) =>
      throw UnimplementedError();

  @override
  Future<bool> fromByteStream(Stream<List<int>> stream, SaveFileMetadata metadata, {Rect? sharePositionOrigin}) =>
      throw UnimplementedError();
}
