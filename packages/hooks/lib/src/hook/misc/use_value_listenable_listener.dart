import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

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
