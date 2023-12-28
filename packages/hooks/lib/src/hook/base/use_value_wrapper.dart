import 'package:utopia_utils/utopia_utils.dart';

import 'use_memoized.dart';

// for convenience
export 'package:utopia_utils/utopia_utils.dart' show ValueExtensions;

Value<T> useValueWrapper<T>(T value) {
  final wrapper = useMemoized(() => MutableValue(value));
  wrapper.value = value;
  return wrapper;
}
