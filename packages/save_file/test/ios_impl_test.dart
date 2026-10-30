import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_save_file/src/impl/native/ios_impl.dart';
import 'package:utopia_save_file/src/model/save_file_metadata.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('utopia_save_file');
  const metadata = SaveFileMetadata(object: '<raw bytes>', mime: 'text/csv', name: 'report.csv');

  late List<MethodCall> calls;
  late String? sharedContent;
  late bool shareResult;

  setUp(() {
    calls = [];
    sharedContent = null;
    shareResult = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      sharedContent = File((call.arguments as Map)['path'] as String).readAsStringSync();
      return shareResult;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  String sharedPath() => (calls.single.arguments as Map)['path'] as String;

  test('shares a temporary file with the requested name and content', () async {
    final result = await SaveFileIosImpl.instance.fromBytes('a,b\n1,2'.codeUnits, metadata);

    expect(result, isTrue);
    expect(calls.single.method, 'share');
    expect(sharedPath().split('/').last, 'report.csv');
    expect(sharedPath(), startsWith(Directory.systemTemp.path));
    expect(sharedContent, 'a,b\n1,2');
  });

  test('deletes the temporary file once the share sheet completes', () async {
    await SaveFileIosImpl.instance.fromBytes([1, 2, 3], metadata);

    expect(File(sharedPath()).existsSync(), isFalse);
    expect(File(sharedPath()).parent.existsSync(), isFalse);
  });

  test('returns false when the share sheet is dismissed', () async {
    shareResult = false;

    expect(await SaveFileIosImpl.instance.fromBytes([1], metadata), isFalse);
  });

  test('passes the share position origin as [left, top, width, height]', () async {
    await SaveFileIosImpl.instance.fromByteStream(
      Stream.value([1]),
      metadata,
      sharePositionOrigin: const Rect.fromLTWH(10, 20, 30, 40),
    );

    expect((calls.single.arguments as Map)['origin'], [10.0, 20.0, 30.0, 40.0]);
  });

  test('omits the origin when not provided', () async {
    await SaveFileIosImpl.instance.fromBytes([1], metadata);

    expect((calls.single.arguments as Map).containsKey('origin'), isFalse);
  });

  test('deletes the temporary file when sharing fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      throw PlatformException(code: 'share_failed');
    });

    await expectLater(SaveFileIosImpl.instance.fromBytes([1], metadata), throwsA(isA<PlatformException>()));
    expect(File(sharedPath()).existsSync(), isFalse);
  });
}
