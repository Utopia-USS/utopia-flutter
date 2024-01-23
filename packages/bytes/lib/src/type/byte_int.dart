import 'dart:typed_data';

import 'package:utopia_bytes/src/type/byte_type.dart';

class ByteInt8 implements ByteType<int> {
  const ByteInt8();

  @override
  int get byteCount => 1;

  @override
  int get(ByteData data, int offset) => data.getInt8(offset);

  @override
  void set(ByteData data, int offset, int value) => data.setInt8(offset, value);
}

class ByteInt16 implements ByteType<int> {
  final Endian endian;

  const ByteInt16(this.endian);

  @override
  int get byteCount => 2;

  @override
  int get(ByteData data, int offset) => data.getInt16(offset, endian);

  @override
  void set(ByteData data, int offset, int value) => data.setInt16(offset, value, endian);
}

class ByteInt32 implements ByteType<int> {
  final Endian endian;

  const ByteInt32(this.endian);

  @override
  int get byteCount => 4;

  @override
  int get(ByteData data, int offset) => data.getInt32(offset, endian);

  @override
  void set(ByteData data, int offset, int value) => data.setInt32(offset, value, endian);
}

class ByteInt64 implements ByteType<int> {
  final Endian endian;

  const ByteInt64(this.endian);

  @override
  int get byteCount => 8;

  @override
  int get(ByteData data, int offset) => data.getInt64(offset, endian);

  @override
  void set(ByteData data, int offset, int value) => data.setInt64(offset, value, endian);
}
