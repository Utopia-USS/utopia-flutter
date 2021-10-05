import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utopia_save_file/utopia_save_file.dart';

const _fileUrl = "https://upload.wikimedia.org/wikipedia/commons/8/80/Wikipedia-logo-v2.svg?download";
const _fileName = "wiki_logo.svg";

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('UtopiaSaveFile example'),
        ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(onPressed: () => _saveFile(context, useName: false), child: const Text("Save without name")),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () => _saveFile(context, useName: true), child: const Text("Save with name")),
      ],
    );
  }

  Future<void> _saveFile(BuildContext context, {required bool useName}) async {
    late String message;
    try {
      setState(() => _isInProgress = true);
      final result = await UtopiaSaveFile.fromUrl(_fileUrl, name: useName ? _fileName : null);
      message = result ? "Success" : "Cancelled";
    } catch (_) {
      message = "Failed";
      rethrow;
    } finally {
      setState(() => _isInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
