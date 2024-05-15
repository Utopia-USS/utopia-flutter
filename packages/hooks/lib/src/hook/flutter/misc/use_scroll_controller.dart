import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

ScrollController useScrollController({
  double initialScrollOffset = 0.0,
  bool keepScrollOffset = true,
  String? debugLabel,
  HookKeys keys = hookKeysEmpty,
}) {
  return useDebugGroup(
    debugLabel: "useScrollController()",
    debugFillProperties: (builder) => builder
      ..add(DoubleProperty("initial offset", initialScrollOffset, defaultValue: 0.0))
      ..add(FlagProperty("keep offset", value: keepScrollOffset, ifFalse: "not keeping offset"))
      ..add(StringProperty("debug label", debugLabel, defaultValue: null))
      ..add(IterableProperty("keys", keys, ifEmpty: null)),
    () {
      return useMemoized(
        () => ScrollController(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        ),
        keys,
        (it) => it.dispose(),
      );
    },
  );
}
