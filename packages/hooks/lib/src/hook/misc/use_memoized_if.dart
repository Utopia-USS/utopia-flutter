import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';

// ignore: avoid_positional_boolean_parameters
T? useMemoizedIf<T>(bool condition, T Function() block, [HookKeys keys = hookKeysEmpty]) =>
    useMemoized(() => condition ? block() : null, [condition, ...keys]);
