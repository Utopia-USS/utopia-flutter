import 'package:web/web.dart';

import 'package:cross_file/cross_file.dart';

Future<XFile> download(String url) async {
  final request = await HttpRequest.request(url, responseType: 'blob');
  final blob = request.response as Blob;
  return XFile(URL.createObjectURL(blob), mimeType: blob.type);
}
