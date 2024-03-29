import 'dart:typed_data';

import 'package:utopia_bytes/src/type/byte_type.dart';

final class ByteReader {
  ByteReader(this.data);

  final ByteData data;

  int _offset = 0;

  int get availableBytes => data.lengthInBytes - _offset;

  T read<T>(ByteType<T> type) {
    final value = type.get(data, _offset);
    _offset += type.byteCount;
    return value;
  }

  T call<T>(ByteType<T> type) => read(type);

  void skip(int byteCount) => _offset += byteCount;

  Uint8List readBytes(int byteCount) {
    final bytes = Uint8List.sublistView(data, _offset, _offset + byteCount);
    _offset += byteCount;
    return bytes;
  }

  ByteReader peek() => ByteReader(ByteData.sublistView(data, _offset));
}
