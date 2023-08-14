// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:cross_file/cross_file.dart';

Future<XFile> download(String url) async {
  final request = await HttpRequest.request(url, responseType: 'blob');
  final blob = request.response as Blob;
  return XFile(Url.createObjectUrlFromBlob(blob), mimeType: blob.type);
}
