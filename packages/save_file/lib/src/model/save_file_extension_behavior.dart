import 'package:utopia_save_file/src/util/extension_helper.dart';

/// Determines what to do if the file extension does not match the mime type.
enum SaveFileExtensionBehavior {
  /// Replace the extension (i.e. the part after the last '.') with the correct one.
  replace,

  /// Append the correct extension. Note that this may result in a file with two extensions (i.e. `file.jpg.png`).
  append,

  /// Ignore the extension mismatch. Note that file may become unreadable.
  ignore,

  /// Throw [SaveFileExtensionException].
  fail,
}
