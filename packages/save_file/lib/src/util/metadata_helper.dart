import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';
import 'package:utopia_save_file/src/util/byte_stream_extensions.dart';
import 'package:utopia_utils/utopia_utils.dart';

class SaveFileMetadataException implements Exception {
  final String object;
  final String? mime, name;

  const SaveFileMetadataException({required this.object, required this.mime, required this.name});

  @override
  String toString() => "Cannot obtain metadata of $object (mime: $mime, name: $name)";
}

abstract class MetadataHelper {
  static final _contentDispositionRegex = RegExp('filename="(.*)"');

  static Future<SaveFileMetadata> fromFile(XFile file, {required String? mime, required String? name}) async {
    return _buildMetadata(
      file.path,
      mime ?? file.mimeType ?? lookupMimeType(file.path, headerBytes: await _getHeaderBytes(file)),
      // Its OK to use '/' as separator, since on native platforms `file.name` is obtained from the path and will
      // never be empty.
      name ?? file.name.takeIf((it) => it.isNotEmpty) ?? file.path.takeIf((it) => it.isNotEmpty)?.split('/').last,
    );
  }

  static Future<SaveFileMetadata> fromUrl(String url, {required String? mime, required String? name}) async {
    if (mime != null && name != null) return _buildMetadata(url, mime, name);
    final uri = Uri.parse(url);
    final response = await http.head(uri);
    final contentType = response.headers['content-type'] ?? response.headers['Content-Type'];
    final contentDisposition = response.headers['content-disposition'] ?? response.headers['Content-Disposition'];
    return _buildMetadata(
      url,
      mime ?? contentType ?? lookupMimeType(uri.path), // TODO possibly fetch header bytes
      name ?? contentDisposition?.let(_getNameFromContentDisposition) ?? uri.pathSegments.last,
    );
  }

  static Future<SaveFileMetadata> fromAsset(
    String key, {
    required String? mime,
    required String? name,
  }) async {
    return _buildMetadata(key, mime ?? lookupMimeType(key), name ?? key.split('/').last);
  }

  static SaveFileMetadata _buildMetadata(String object, String? mime, String? name) {
    if (mime == null || name == null) throw SaveFileMetadataException(object: object, mime: mime, name: name);
    return SaveFileMetadata(object: object, mime: mime, name: name);
  }

  static Future<List<int>> _getHeaderBytes(XFile file) async =>
      file.openRead(0, defaultMagicNumbersMaxLength).toBytes();

  static String? _getNameFromContentDisposition(String header) => _contentDispositionRegex.firstMatch(header)?.group(1);
}
