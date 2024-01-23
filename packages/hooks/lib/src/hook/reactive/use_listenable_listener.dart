import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

void useListenableListener(Listenable? listenable, void Function() block) {
  final wrappedBlock = useValueWrapper(block);
  useEffect(() {
    if (listenable != null) {
      void listener() => wrappedBlock.value();
      listenable.addListener(listener);
      return () => listenable.removeListener(listener);
    }
    return null;
  }, [listenable]);
}

void useValueListenableListener<T>(ValueListenable<T>? listenable, void Function(T) block) =>
    useListenableListener(listenable, () => block(listenable!.value));

void useListenableValueListener<T>(ListenableValue<T>? listenable, void Function(T) block) =>
    useListenableListener(listenable, () => block(listenable!.value));
