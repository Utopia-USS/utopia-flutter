import 'dart:typed_data';

import 'package:utopia_bytes/src/byte_reader.dart';
import 'package:utopia_bytes/src/byte_writer.dart';
import 'package:utopia_bytes/src/type/byte_float.dart';
import 'package:utopia_bytes/src/type/byte_int.dart';
import 'package:utopia_bytes/src/type/byte_type.dart';
import 'package:utopia_bytes/src/type/byte_uint.dart';

final class Bytes {
  const Bytes._();

  static R read<R>(TypedData bytes, R Function(ByteReader reader) block) =>
      block(ByteReader(ByteData.sublistView(bytes)));

  static T readSingle<T>(TypedData bytes, ByteType<T> type) => read(bytes, (reader) => reader(type));

  static Uint8List write(void Function(ByteWriter writer) block) {
    final writer = ByteWriter();
    block(writer);
    return Uint8List.sublistView(writer.toByteData());
  }

  static Uint8List writeSingle<T>(ByteType<T> type, T value) => write((writer) => writer(type, value));

  static const uint8 = ByteUint8();
  static const uint16LE = ByteUint16(Endian.little);
  static const uint16BE = ByteUint16(Endian.big);
  static const uint32LE = ByteUint32(Endian.little);
  static const uint32BE = ByteUint32(Endian.big);
  static const uint64LE = ByteUint64(Endian.little);
  static const uint64BE = ByteUint64(Endian.big);
  static const int8 = ByteInt8();
  static const int16LE = ByteInt16(Endian.little);
  static const int16BE = ByteInt16(Endian.big);
  static const int32LE = ByteInt32(Endian.little);
  static const int32BE = ByteInt32(Endian.big);
  static const int64LE = ByteInt64(Endian.little);
  static const int64BE = ByteInt64(Endian.big);
  static const float32LE = ByteFloat32(Endian.little);
  static const float32BE = ByteFloat32(Endian.big);
  static const float64LE = ByteFloat64(Endian.little);
  static const float64BE = ByteFloat64(Endian.big);
}
