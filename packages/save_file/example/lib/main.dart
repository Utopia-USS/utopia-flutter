import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:utopia_save_file/utopia_save_file.dart';

import 'download_io.dart' if (dart.library.js) 'download_web.dart';

const _fileUrl = "https://upload.wikimedia.org/wikipedia/commons/8/80/Wikipedia-logo-v2.svg?download";
const _fileUrlName = "wiki_logo";
const _fileBytesName = "alamakota";
const _fileBytesMime = "text/plain";

Stream<List<int>> _buildFileBytes() =>
    Stream.fromIterable(["ala", "ma", "kota"]).map((it) => Uint8ClampedList.fromList(it.codeUnits));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInProgress = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('UtopiaSaveFile example')),
        body: Builder(
          builder: (context) => Center(
            child: _isInProgress ? _buildLoader() : _buildButtons(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() => const CircularProgressIndicator();

  Widget _buildButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => _saveUrl(context, useName: false),
          child: const Text("Save without name"),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _saveUrl(context, useName: true),
          child: const Text("Save with name"),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _saveBytes(context),
          child: const Text("Save bytes"),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _saveFile(context),
          child: const Text("Save file"),
        ),
      ],
    );
  }

  Future<void> _saveUrl(BuildContext context, {required bool useName}) async =>
      _runWithProgress(context, () => UtopiaSaveFile.fromUrl(_fileUrl, name: useName ? _fileUrlName : null));

  Future<void> _saveBytes(BuildContext context) async {
    await _runWithProgress(
      context,
      () => UtopiaSaveFile.fromByteStream(_buildFileBytes(), name: _fileBytesName, mime: _fileBytesMime),
    );
  }

  Future<void> _saveFile(BuildContext context) async =>
      _runWithProgress(context, () async => UtopiaSaveFile.fromFile(await download(_fileUrl), name: _fileUrlName));

  Future<void> _runWithProgress(BuildContext context, Future<bool> Function() block) async {
    late String message;
    try {
      setState(() => _isInProgress = true);
      message = await block() ? "Success" : "Cancelled";
    } catch (_) {
      message = "Failed";
      rethrow;
    } finally {
      setState(() => _isInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
