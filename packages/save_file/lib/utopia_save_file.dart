/// @docImport 'dart:html';
/// @docImport 'package:utopia_save_file/utopia_save_file_web.dart';
library;

import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:mime/mime.dart';
import 'package:utopia_save_file/src/impl/impl.dart';
import 'package:utopia_save_file/src/model/save_file_extension_behavior.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';
import 'package:utopia_save_file/src/util/extension_helper.dart';
import 'package:utopia_save_file/src/util/metadata_helper.dart';

export 'src/model/save_file_extension_behavior.dart';
export 'src/util/extension_helper.dart' show SaveFileExtensionException;
export 'src/util/metadata_helper.dart' show SaveFileMetadataException;

sealed class UtopiaSaveFile {
  static final _impl = SaveFileImpl.instance;

  /// Copies provided [file] to a location where it's accessible by the user.
  ///
  /// {@template utopia_save_file.return}
  /// Returns `true` if the file has been saved and `false` if user has cancelled the action
  /// (can happen only on Android). Throws if there's been an error.
  /// {@endtemplate}
  ///
  /// If [mime] or [name] parameters are not provided, they will be inferred using the following methods, in order:
  /// For [mime] :
  /// 1. [XFile.mimeType] parameter
  /// 2. [lookupMimeType] function
  ///   i. Using magic bytes
  ///   ii. Using file extension
  /// For [name] :
  /// 1. [XFile.name] parameter
  /// 2. Last segment of [XFile.path]
  ///
  /// {@template utopia_save_file.extensionBehavior}
  /// The [extensionBehavior] parameter determines what to do if the extension of provided or inferred [name]
  /// does not match the provided or inferred [mime] type.
  /// See [SaveFileExtensionBehavior] for documentation of the available options.
  /// {@endtemplate}
  ///
  /// On native platforms, [file] must be accessible by the app.
  ///
  /// On the Web, [file] can point to an arbitrary URL but consider using the following, more specialized APIs:
  /// - [UtopiaSaveFileWeb.fromBlob] convenience method for [Blob]s
  /// - [fromUrl] for HTTP(S) URLs
  static Future<bool> fromFile(
    XFile file, {
    String? mime,
    String? name,
    SaveFileExtensionBehavior extensionBehavior = SaveFileExtensionBehavior.replace,
  }) async {
    final metadata = await MetadataHelper.fromFile(file, mime: mime, name: name);
    return _impl.fromFile(file, ExtensionHelper.ensureValid(metadata, extensionBehavior));
  }

  /// Downloads file from the provided [url] and saves it to a location where it's accessible by the user.
  ///
  /// The [url] will be downloaded by executing a GET request without any additional headers.
  /// {@macro utopia_save_file.return}
  ///
  /// If [mime] or [name] parameters are not provided, they will be inferred using the following methods, in order:
  /// For [mime]:
  /// 1. `Content-Type` header returned via a `HEAD` request.
  /// 2. [lookupMimeType] function using the last path segment.
  /// For [name]:
  /// 1. `Content-Disposition` header returned via a `HEAD` request.
  /// 2. Last path segment.
  ///
  /// {@macro utopia_save_file.extensionBehavior}
  ///
  /// On the Web, when [url] is cross-origin, server should send the `Content-Disposition: attachment` header to
  /// prevent the browser from blocking the request. However, if the `filename` parameter is also sent in the header,
  /// it will override the [name] parameter.
  ///
  /// {@template utopia_save_file.webBehavior}
  /// On the Web, method will complete immediately and start the download in the background, without the ability
  /// to monitor its status. To gain more control over this process, consider using [HttpRequest.request] with
  /// `responseType: 'blob'` and then [UtopiaSaveFileWeb.fromBlob].
  /// {@endtemplate}
  static Future<bool> fromUrl(
    String url, {
    String? name,
    String? mime,
    SaveFileExtensionBehavior extensionBehavior = SaveFileExtensionBehavior.replace,
  }) async {
    final metadata = await MetadataHelper.fromUrl(url, mime: mime, name: name);
    return _impl.fromUrl(url, ExtensionHelper.ensureValid(metadata, extensionBehavior));
  }

  /// Copies asset at [key] to a location where it's accessible by the user.
  ///
  /// {@macro utopia_save_file.return}
  ///
  /// If [mime] or [name] parameters are not provided, they will be inferred using the following methods:
  /// For [mime]: [lookupMimeType] function (using file extension).
  /// For [name]: Last segment of [key].
  ///
  /// {@macro utopia_save_file.extensionBehavior}
  ///
  /// {@macro utopia_save_file.webBehavior}
  static Future<bool> fromAsset(
    String key, {
    String? mime,
    String? name,
    SaveFileExtensionBehavior extensionBehavior = SaveFileExtensionBehavior.replace,
  }) async {
    final metadata = await MetadataHelper.fromAsset(key, mime: mime, name: name);
    return _impl.fromAsset(key, ExtensionHelper.ensureValid(metadata, extensionBehavior));
  }

  /// Saves provided byte [stream] to file in a location accessible by the user.
  ///
  /// {@macro utopia_save_file.return}
  ///
  /// {@template utopia_save_file.noInference}
  /// Both [mime] and [name] parameters must be provided. To allow for automatic inference,
  /// use [fromFile] or [fromUrl] methods.
  /// {@endtemplate}
  ///
  /// {@macro utopia_save_file.extensionBehavior}
  static Future<bool> fromByteStream(
    Stream<List<int>> stream, {
    required String mime,
    required String name,
    SaveFileExtensionBehavior extensionBehavior = SaveFileExtensionBehavior.replace,
  }) async {
    final metadata = SaveFileMetadata(object: '<raw byte stream>', name: name, mime: mime);
    return _impl.fromByteStream(stream, ExtensionHelper.ensureValid(metadata, extensionBehavior));
  }

  /// Saves provided [bytes] to file in a location accessible by the user.
  ///
  /// {@macro utopia_save_file.return}
  ///
  /// {@macro utopia_save_file.noInference}
  ///
  /// {@macro utopia_save_file.extensionBehavior}
  ///
  /// For bigger files, consider using a streaming approach with [fromByteStream] to avoid loading the whole file
  /// to memory.
  static Future<bool> fromBytes(
    List<int> bytes, {
    required String mime,
    required String name,
    SaveFileExtensionBehavior extensionBehavior = SaveFileExtensionBehavior.replace,
  }) async {
    final metadata = SaveFileMetadata(object: '<raw bytes>', name: name, mime: mime);
    return _impl.fromBytes(bytes, ExtensionHelper.ensureValid(metadata, extensionBehavior));
  }
}
