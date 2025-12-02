import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

T? usePreviousIfNull<T>(T? value, {HookKeys keys = hookKeysEmpty}) {
  return useDebugGroup(
    debugLabel: "usePreviousIfNull<$T>()",
    debugFillProperties: (builder) => builder
      ..add(DiagnosticsProperty("value", value))
      ..add(HookKeysProperty(keys)),
    () {
      final state = useMemoized(() => MutableValue<T?>(null), keys);
      if (value != null) state.value = value;
      return state.value;
    },
  );
}
