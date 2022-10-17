import 'dart:typed_data';

abstract class ByteType<T> {
  abstract final int byteCount;
  T get(ByteData data, int offset);
  void set(ByteData data, int offset, T value);
}
