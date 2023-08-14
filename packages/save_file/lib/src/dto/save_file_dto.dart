import 'package:utopia_save_file/src/model/save_file_metadata.dart';

sealed class SaveFileDto {
  final String name, mime;

  SaveFileDto(SaveFileMetadata metadata)
      : name = metadata.name,
        mime = metadata.mime;

  Map<String, dynamic> toMap() => {"name": name, "mime": mime};

  static const fromFile = SaveFileDtoFromFile.new;
  static const fromUrl = SaveFileDtoFromUrl.new;
  static const fromBytes = SaveFileDtoFromBytes.new;
}

final class SaveFileDtoFromFile extends SaveFileDto {
  final String path;

  SaveFileDtoFromFile(super.metadata, {required this.path});

  @override
  Map<String, dynamic> toMap() => {...super.toMap(), "path": path};
}

final class SaveFileDtoFromUrl extends SaveFileDto {
  final String url;

  SaveFileDtoFromUrl(super.metadata, {required this.url});

  @override
  Map<String, dynamic> toMap() => {...super.toMap(), "url": url};
}

final class SaveFileDtoFromBytes extends SaveFileDto {
  final List<int> bytes;

  SaveFileDtoFromBytes(super.metadata, {required this.bytes});

  @override
  Map<String, dynamic> toMap() => {...super.toMap(), "bytes": bytes};
}
