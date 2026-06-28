<img src="https://raw.githubusercontent.com/Utopia-USS/utopia-flutter/master/packages/bytes/docs/header.png" width="221" alt="Utopia Bytes"/>

# utopia_bytes

Typed binary serialisation helpers for Dart. Provides `ByteReader` and `ByteWriter` for sequential reads and writes over `ByteData`, a `ByteType<T>` interface for typed codec descriptors, and the `Bytes` facade with pre-built constants for all common widths and endiannesses (uint8, uint16/32/64 LE/BE, int8, int16/32/64 LE/BE, float32/64 LE/BE).

```dart
// Write two fields
final bytes = Bytes.write((w) {
  w(Bytes.uint16LE, 0x1234);
  w(Bytes.float32LE, 3.14);
});

// Read them back
final value = Bytes.read(bytes, (r) {
  final id = r(Bytes.uint16LE);
  final temp = r(Bytes.float32LE);
  return (id, temp);
});
```