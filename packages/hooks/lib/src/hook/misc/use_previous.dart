import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

T? usePrevious<T>(T value) {
  return useDebugGroup(
    debugLabel: "usePrevious<$T>()",
    debugFillProperties: (builder) => builder.add(DiagnosticsProperty("value", value)),
    () {
      final prev = useState<T?>(null, listen: false);
      final prevValue = prev.value;
      prev.value = value;
      return prevValue;
    },
  );
}
