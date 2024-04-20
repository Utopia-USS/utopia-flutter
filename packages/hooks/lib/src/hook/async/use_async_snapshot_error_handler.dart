import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

void useAsyncSnapshotErrorHandler(AsyncSnapshot<Object?>? snapshot, {void Function(Object, StackTrace)? onError}) {
  useDebugGroup(
    debugLabel: "useAsyncSnapshotErrorHandler()",
    debugFillProperties: (builder) => builder
      ..add(EnumProperty("state", snapshot?.connectionState))
      ..add(DiagnosticsProperty("error", snapshot?.error)),
    () {
      onError ??= Zone.current.handleUncaughtError;

      useEffect(() {
        if (snapshot?.hasError ?? false) onError!(snapshot!.error!, snapshot.stackTrace!);
        return null;
      }, [snapshot?.error, snapshot?.stackTrace]);
    },
  );
}
