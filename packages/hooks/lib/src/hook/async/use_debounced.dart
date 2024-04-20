import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

T useDebounced<T>(T value, {required Duration duration}) {
  return useDebugGroup(
    debugLabel: "useDebounced<$T>()",
    debugFillProperties: (builder) => builder
      ..add(DiagnosticsProperty("value", value))
      ..add(DiagnosticsProperty("duration", duration)),
    () {
      final valueState = useState(value);
      final isMounted = useIsMounted();

      useEffect(() {
        final timer = Timer(duration, () {
          if (isMounted()) valueState.value = value;
        });
        return timer.cancel;
      }, [value]);

      return valueState.value;
    },
  );
}
