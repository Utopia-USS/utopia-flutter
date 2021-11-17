import 'dart:html' as html;

import 'package:utopia_save_file/src/util/byte_stream_extensions.dart';

class UtopiaSaveFileImpl {
  static Future<bool> fromUrl(String url, {String? name}) async {
    html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    anchorElement.download = name;
    anchorElement.click();
    return true;
  }

  static Future<bool> fromByteStream(Stream<List<int>> stream, {required String name, required String mime}) async {
    final uri = Uri.dataFromBytes(await stream.toBytes(), mimeType: mime);
    return fromUrl(uri.toString(), name: name);
  }
}