import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

T? usePreviousIfNull<T>(T? value) {
  return useDebugGroup(
    debugLabel: "usePreviousIfNull<$T>()",
    debugFillProperties: (builder) => builder.add(DiagnosticsProperty("value", value)),
    () {
      final state = useState<T?>(null, listen: false);
      if (value != null) state.value = value;
      return state.value;
    },
  );
}
