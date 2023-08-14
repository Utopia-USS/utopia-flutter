import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

Future<XFile> download(String url) async {
  final directory = await getTemporaryDirectory();
  final request = await HttpClient().getUrl(Uri.parse(url));
  final response = await request.close();
  final file = File('${directory.path}/download.${extensionFromMime(response.headers.contentType!.mimeType)}');
  await response.pipe(file.openWrite());
  return XFile(file.path);
}
