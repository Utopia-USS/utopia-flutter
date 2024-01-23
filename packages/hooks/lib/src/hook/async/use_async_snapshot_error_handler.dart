import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';

void useAsyncSnapshotErrorHandler(AsyncSnapshot<Object?> snapshot, {void Function(Object, StackTrace)? onError}) {
  onError ??= Zone.current.handleUncaughtError;

  useEffect(() {
    if (snapshot.hasError) onError!(snapshot.error!, snapshot.stackTrace!);
    return null;
  }, [snapshot.error, snapshot.stackTrace]);
}
