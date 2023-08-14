import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:utopia_save_file/src/dto/save_file_dto.dart';
import 'package:utopia_save_file/src/impl/native_impl.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';
import 'package:utopia_save_file/src/util/byte_stream_extensions.dart';

class SaveFileAndroidImpl implements SaveFileNativeImpl {
  static const _channel = MethodChannel('utopia_save_file');

  static const instance = SaveFileAndroidImpl._();

  const SaveFileAndroidImpl._();

  @override
  Future<bool> fromFile(XFile file, SaveFileMetadata metadata) async =>
      _execute('fromFile', SaveFileDto.fromFile(metadata, path: file.path));

  @override
  Future<bool> fromUrl(String url, SaveFileMetadata metadata) async =>
      _execute('fromUrl', SaveFileDto.fromUrl(metadata, url: url));

  @override
  Future<bool> fromBytes(List<int> bytes, SaveFileMetadata metadata) async =>
      _execute('fromBytes', SaveFileDto.fromBytes(metadata, bytes: bytes));

  // TODO implement streaming
  @override
  Future<bool> fromByteStream(Stream<List<int>> stream, SaveFileMetadata metadata) async =>
      fromBytes(await stream.toBytes(), metadata);

  static Future<bool> _execute(String method, SaveFileDto dto) async =>
      (await _channel.invokeMethod<bool>(method, dto.toMap()))!;
}
