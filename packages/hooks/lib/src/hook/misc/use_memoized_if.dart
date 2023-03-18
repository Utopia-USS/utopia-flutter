import 'package:utopia_hooks/utopia_hooks.dart';

// ignore: avoid_positional_boolean_parameters
T? useMemoizedIf<T>(bool condition, T Function() block, [List<Object?>? keys]) =>
    useMemoized(() => condition ? block() : null, [condition, ...?keys]);
