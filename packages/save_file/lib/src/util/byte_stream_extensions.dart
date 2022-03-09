import 'dart:async';
import 'dart:convert';

extension ByteStreamExtensions on Stream<List<int>> {
  // based on https://pub.dev/documentation/http/latest/http/ByteStream/toBytes.html
  Future<List<int>> toBytes() {
    final completer = Completer<List<int>>();
    final sink = ByteConversionSink.withCallback(completer.complete);
    listen(
      sink.add,
      onError: completer.completeError,
      onDone: sink.close,
      cancelOnError: true,
    );
    return completer.future;
  }
}
