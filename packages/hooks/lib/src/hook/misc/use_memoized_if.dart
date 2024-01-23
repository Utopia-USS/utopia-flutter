import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';

// ignore: avoid_positional_boolean_parameters
T? useMemoizedIf<T>(bool condition, T Function() block, [HookKeys keys = const[]]) =>
    useMemoized(() => condition ? block() : null, [condition, ...keys]);
