import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

import '../base/use_state.dart';

int usePeriodicalSignal({required Duration period, bool enabled = true}) {
  return useDebugGroup(
    debugLabel: "usePeriodicalSignal()",
    debugFillProperties: (properties) => properties
      ..add(DiagnosticsProperty("period", period))
      ..add(FlagProperty("enabled", value: enabled, ifFalse: "disabled")),
    () {
      final state = useState(0);
      final isMounted = useIsMounted();

      useEffect(() {
        if (enabled) {
          final timer = Timer.periodic(period, (_) {
            if (isMounted()) state.value++;
          });
          return timer.cancel;
        }
        return null;
      }, [enabled]);

      return state.value;
    },
  );
}
