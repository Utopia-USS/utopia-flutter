import 'package:flutter_hooks/flutter_hooks.dart';

void useStreamSubscription<T>(Stream<T>? stream, Function(T) block) {
  useEffect(() {
    final subscription = stream?.listen(block);
    return () => subscription?.cancel();
  }, [stream]);
}
