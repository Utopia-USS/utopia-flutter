import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

export 'package:clock/clock.dart' show clock;
export 'package:fake_async/fake_async.dart' show FakeAsync;

Future<void> asyncYield() => Future(() {});

Matcher after(DateTime value) => _AfterMatcher(value);

class _AfterMatcher extends Matcher {
  final DateTime value;

  const _AfterMatcher(this.value);

  @override
  Description describe(Description description) => description.add('DateTime after').addDescriptionOf(value);

  @override
  // ignore: avoid_annotating_with_dynamic
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) => item is DateTime && item.isAfter(value);
}

/// A test helper that wraps a test body in [fakeAsync] for time manipulation.
void Function() withFakeAsync(void Function(FakeAsync async) testBody) {
  return () => fakeAsync(testBody);
}
