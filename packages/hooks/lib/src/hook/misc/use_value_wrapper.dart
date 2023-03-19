import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

// for convenience
export 'package:utopia_utils/utopia_utils.dart' show ValueExtensions;

Value<T> useValueWrapper<T>(T value) {
  final wrapper = useMemoized(() => MutableValue(value));
  wrapper.value = value;
  return wrapper;
}
