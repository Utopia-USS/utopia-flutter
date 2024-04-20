import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_utils/utopia_utils.dart';

import 'use_memoized.dart';

// for convenience
export 'package:utopia_utils/utopia_utils.dart' show ValueExtensions;

Value<T> useValueWrapper<T>(T value) {
  return useDebugGroup(debugLabel: 'useValueWrapper<$T>()', () {
    final wrapper = useMemoized(() => MutableValue(value));
    wrapper.value = value;
    return wrapper;
  });
}
