import 'dart:js_interop';

import 'package:cross_file/cross_file.dart';
import 'package:web/web.dart';

Future<XFile> download(String url) async {
  final response = await window.fetch(url.toJS).toDart;
  final blob = await response.blob().toDart;
  return XFile(URL.createObjectURL(blob), mimeType: blob.type);
}
