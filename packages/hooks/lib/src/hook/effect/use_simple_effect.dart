import 'package:flutter_hooks/flutter_hooks.dart';

void useSimpleEffect(void Function() effect, [List<Object?>? keys]) {
  useEffect(
    () {
      Future.microtask(() => effect());
      return null;
    },
    keys);
}

void useSimpleEffectIfNotNull<T extends Object>(T? value, void Function(T) effect, [List<Object?>? keys]) {
  useSimpleEffect(() {
    if (value != null) effect(value);
  }, [value, ...?keys]);
}
