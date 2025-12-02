import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

@Deprecated("This hook is unsafe as it depends on the rebuild frequency. Use usePreviousValue or useEffect instead")
T? usePrevious<T>(T value, {HookKeys keys = hookKeysEmpty}) {
  return useDebugGroup(
    debugLabel: "usePrevious<$T>()",
    debugFillProperties: (builder) => builder.add(DiagnosticsProperty("value", value)),
    () {
      final prev = useMemoized(() => MutableValue<T?>(null), keys);
      final prevValue = prev.value;
      prev.value = value;
      return prevValue;
    },
  );
}

T? usePreviousValue<T>(T value, {HookKeys keys = hookKeysEmpty}) {
  return useDebugGroup(
    debugLabel: "usePreviousValue<$T>()",
    debugFillProperties: (builder) => builder.add(DiagnosticsProperty("value", value)),
    () {
      final curr = useMemoized(() => MutableValue<T>(value), keys);
      final prev = useMemoized(() => MutableValue<T?>(null), keys);
      if (curr.value != value) {
        prev.value = curr.value;
        curr.value = value;
      }
      return prev.value;
    },
  );
}

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
