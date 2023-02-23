import 'package:utopia_utils/utopia_utils.dart';

class ByteCoder<T> {
  const ByteCoder(this.type);

  final ByteType<T> type;

  void write(ByteWriter writer, T value) => writer(type, value);

  T read(ByteReader reader) => reader(type);
}
