import 'dart:html';

import 'package:cross_file/cross_file.dart';
import 'package:utopia_save_file/utopia_save_file.dart';

export 'utopia_save_file.dart';

sealed class UtopiaSaveFileWeb {
  static Future<void> fromBlob(Blob blob, {String? name, String? mime}) =>
      UtopiaSaveFile.fromFile(XFile(Url.createObjectUrlFromBlob(blob)), name: name, mime: mime ?? blob.type);
}
