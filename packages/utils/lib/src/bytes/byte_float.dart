import 'dart:typed_data';

import 'package:utopia_utils/src/bytes/byte_type.dart';

class ByteFloat32 implements ByteType<double> {
  final Endian endian;

  const ByteFloat32(this.endian);

  @override
  int get byteCount => 4;

  @override
  double get(ByteData data, int offset) => data.getFloat32(offset, endian);

  @override
  void set(ByteData data, int offset, double value) => data.setFloat32(offset, value, endian);
}

class ByteFloat64 implements ByteType<double> {
  final Endian endian;

  const ByteFloat64(this.endian);

  @override
  int get byteCount => 8;

  @override
  double get(ByteData data, int offset) => data.getFloat64(offset, endian);

  @override
  void set(ByteData data, int offset, double value) => data.setFloat64(offset, value, endian);
}
