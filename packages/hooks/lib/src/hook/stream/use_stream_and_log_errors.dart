import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

AsyncSnapshot<T> useStreamAndLogErrors<T>(Stream<T> stream, {required T initialData}) {
  return useStream(
    useMemoized(
      () async* {
        try {
          await for (final value in stream) {
            yield value;
          }
        } catch (e, s) {
          UtopiaHooks.reporter?.error('Error in useStream', e: e, s: s);
        }
      },
      [stream],
    ),
    initialData: initialData,
  );
}
