import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';

ScrollController useScrollController({
  double initialScrollOffset = 0.0,
  bool keepScrollOffset = true,
  String? debugLabel,
  HookKeys keys = const [],
}) {
  return useMemoized(
    () => ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      debugLabel: debugLabel,
    ),
    keys,
    (it) => it.dispose(),
  );
}
