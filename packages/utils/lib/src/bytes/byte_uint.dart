import 'dart:typed_data';

import 'package:utopia_utils/src/bytes/byte_type.dart';

class ByteUint8 implements ByteType<int> {
  const ByteUint8();

  @override
  int get byteCount => 1;

  @override
  int get(ByteData data, int offset) => data.getUint8(offset);

  @override
  void set(ByteData data, int offset, int value) => data.setUint8(offset, value);
}

class ByteUint16 implements ByteType<int> {
  final Endian endian;

  const ByteUint16(this.endian);

  @override
  int get byteCount => 2;

  @override
  int get(ByteData data, int offset) => data.getUint16(offset, endian);

  @override
  void set(ByteData data, int offset, int value) => data.setUint16(offset, value, endian);
}

class ByteUint32 implements ByteType<int> {
  final Endian endian;

  const ByteUint32(this.endian);

  @override
  int get byteCount => 4;

  @override
  int get(ByteData data, int offset) => data.getUint32(offset, endian);

  @override
  void set(ByteData data, int offset, int value) => data.setUint32(offset, value, endian);
}

class ByteUint64 implements ByteType<int> {
  final Endian endian;

  const ByteUint64(this.endian);

  @override
  int get byteCount => 8;

  @override
  int get(ByteData data, int offset) => data.getUint64(offset, endian);

  @override
  void set(ByteData data, int offset, int value) => data.setUint64(offset, value, endian);
}