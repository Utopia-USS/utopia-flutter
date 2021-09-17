import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useValueListenableListener<T>(ValueListenable<T> listenable, Function(T) block) {
  useEffect(
    () {
      final listener = () => block(listenable.value);
      listenable.addListener(listener);
      return () => listenable.removeListener(listener);
    },
    [listenable],
  );
}
