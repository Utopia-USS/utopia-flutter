import 'dart:async';

import 'src/utopia_save_file_impl.dart' if (dart.library.js) 'src/utopia_save_file_impl_web.dart';

class UtopiaSaveFile {
  /// Downloads and saves file from provided [url].
  /// If [name] parameter is not provided, it will be inferred from last part of the [url].
  /// Returns `true` if file has been saved.
  /// Returns `false` if user has cancelled the action (can happen only on Android).
  /// Throws if there's been an error.
  ///
  /// On Android, launches system "files" app and allows user to select the destination and filename.
  /// Uses `Intent.CREATE_DOCUMENT` and `ContentResolver` under the hood.
  /// No `WRITE_EXTERNAL_STORAGE` permission needed.
  /// [name] parameter is the suggested file name, user may change it during saving.
  ///
  /// On iOS, saves to application documents directory, but files will be visible in system "Files" app.
  /// Remember to add to `Info.plist`:
  /// ```
  /// <key>NSAllowsArbitraryLoads</key>
  /// <true/>
  /// <key>LSSupportsOpeningDocumentsInPlace</key>
  /// <true/>
  /// <key>UIFileSharingEnabled</key>
  /// <true/>
  /// ```
  /// [name] parameter designates the file name.
  ///
  /// On Web, downloads the file using standard browser APIs.
  /// [url] must be served with `Content-Disposition: attachment` header, otherwise file will open in the browser.
  /// [name] parameter is ignored. File name depends on `Content-Disposition` header value and browser behaviour.
  static Future<bool> fromUrl(String url, {String? name}) async => await UtopiaSaveFileImpl.fromUrl(url, name: name);

  /// Saves provided byte [stream] to file.
  /// Returns `true` if file has been saved.
  /// Returns `false` if user has cancelled the action (can happen only on Android).
  /// Throws if there's been an error.
  ///
  /// On Android, launches system "files" app and allows user to select the destination and filename.
  /// Uses `Intent.CREATE_DOCUMENT` and `ContentResolver` under the hood.
  /// No `WRITE_EXTERNAL_STORAGE` permission needed.
  /// [name] parameter is the suggested file name, user may change it during saving.
  /// [mime] parameter is required and allows system to select file extension and suggested location.
  ///
  /// On iOS, saves to application documents directory, but files will be visible in system "Files" app.
  /// Remember to add to `Info.plist`:
  /// ```
  /// <key>NSAllowsArbitraryLoads</key>
  /// <true/>
  /// <key>LSSupportsOpeningDocumentsInPlace</key>
  /// <true/>
  /// <key>UIFileSharingEnabled</key>
  /// <true/>
  /// ```
  /// [name] designates the file name.
  ///
  /// On Web, saves the file by data URI using standard browser APIs.
  static Future<bool> fromByteStream(Stream<List<int>> stream, {required String name, required String mime}) async =>
      await UtopiaSaveFileImpl.fromByteStream(stream, name: name, mime: mime);

  /// Saves provided [bytes] to file.
  /// See [fromByteStream].
  static Future<bool> fromBytes(List<int> bytes, {required String name, required String mime}) async =>
      await UtopiaSaveFileImpl.fromByteStream(Stream.value(bytes), name: name, mime: mime);
}
