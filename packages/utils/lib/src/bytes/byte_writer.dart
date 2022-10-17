import 'dart:typed_data';

import 'package:utopia_utils/src/bytes/byte_type.dart';

class ByteWriter {
  var _totalBytes = 0;
  final _writers = <int Function(ByteData data, int offset)>[];

  void write<T>(ByteType<T> type, T value) {
    _totalBytes += type.byteCount;
    _writers.add((data, offset) {
      type.set(data, offset, value);
      return type.byteCount;
    });
  }

  void call<T>(ByteType<T> type, T value) => write(type, value);

  void writeBytes(Uint8List bytes) {
    _totalBytes += bytes.length;
    _writers.add((dstData, offset) {
      final dstBytes = Uint8List.sublistView(dstData, offset);
      for(var i = 0; i < bytes.length; i++) {
        dstBytes[i] = bytes[i];
      }
      return bytes.length;
    });
  }

  ByteData toByteData() {
    final data = ByteData(_totalBytes);
    var offset = 0;
    for(final writer in _writers) {
      final bytesWritten = writer(data, offset);
      offset += bytesWritten;
    }
    return data;
  }
}