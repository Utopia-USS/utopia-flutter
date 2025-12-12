import 'package:mime/mime.dart';
import 'package:utopia_save_file/src/model/save_file_extension_behavior.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';

abstract class SaveFileExtensionException implements Exception {
  final SaveFileMetadata metadata;

  const SaveFileExtensionException(this.metadata);
}

class SaveFileInvalidExtensionException extends SaveFileExtensionException {
  const SaveFileInvalidExtensionException(super.metadata);

  @override
  String toString() => "Extension doesn't match for $metadata";
}

class SaveFileUnknownExtensionException extends SaveFileExtensionException {
  const SaveFileUnknownExtensionException(super.metadata);

  @override
  String toString() => "Cannot infer extension for $metadata";
}

abstract class ExtensionHelper {
  static SaveFileMetadata ensureValid(SaveFileMetadata metadata, SaveFileExtensionBehavior behavior) {
    if (behavior == SaveFileExtensionBehavior.ignore || lookupMimeType(metadata.name) == metadata.mime) return metadata;
    late final extension = extensionFromMime(metadata.mime) ?? (throw SaveFileUnknownExtensionException(metadata));
    final name = switch (behavior) {
      SaveFileExtensionBehavior.replace => _replaceExtension(metadata.name, extension),
      SaveFileExtensionBehavior.append => _appendExtension(metadata.name, extension),
      SaveFileExtensionBehavior.ignore => throw StateError("Unreachable"),
      SaveFileExtensionBehavior.fail => throw SaveFileInvalidExtensionException(metadata),
    };
    return metadata.copyWith(name: name);
  }

  static String addCounter(String name, int counter) {
    final (basename, extension) = _splitExtension(name);
    return _appendExtension("$basename ($counter)", extension);
  }

  static String _replaceExtension(String name, String extension) =>
      _appendExtension(_splitExtension(name).$1, extension);

  static String _appendExtension(String name, String? extension) => extension != null ? "$name.$extension" : name;

  static (String, String?) _splitExtension(String name) {
    final index = name.lastIndexOf('.');
    return index == -1 ? (name, null) : (name.substring(0, index), name.substring(index + 1));
  }
}
