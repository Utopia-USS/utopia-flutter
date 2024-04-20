import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

void useListenableListener(Listenable? listenable, void Function() block) =>
    _useListenableListener(listenable, block, debugLabel: "useListenableListener()");

void useValueListenableListener<T>(ValueListenable<T>? listenable, void Function(T) block) =>
    _useListenableListener(listenable, () => block(listenable!.value), debugLabel: "useValueListenableListener<$T>()");

void useListenableValueListener<T>(ListenableValue<T>? listenable, void Function(T) block) =>
    _useListenableListener(listenable, () => block(listenable!.value), debugLabel: "useListenableValueListener<$T>()");

void _useListenableListener(Listenable? listenable, void Function() block, {required String debugLabel}) {
  useDebugGroup(
    debugLabel: debugLabel,
    debugFillProperties: (builder) =>
        builder.add(DiagnosticsProperty("listenable", listenable, ifNull: "no listenable", showName: false)),
    () {
      final wrappedBlock = useValueWrapper(block);
      useEffect(() {
        if (listenable != null) {
          void listener() => wrappedBlock.value();
          listenable.addListener(listener);
          return () => listenable.removeListener(listener);
        }
        return null;
      }, [listenable]);
    },
  );
}
