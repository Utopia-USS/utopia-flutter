import 'package:flutter/cupertino.dart';
import 'package:utopia_arch/src/navigation/scoped_navigator_state.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

@Deprecated("Use context.navigator or navigatorKey passing")
NavigatorState useScopedNavigator() => useProvided<ScopedNavigatorState>().navigatorKey.currentState!;
