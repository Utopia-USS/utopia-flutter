import 'package:flutter/cupertino.dart';
import 'package:utopia_arch/navigation/scoped_navigator_state.dart';
import 'package:utopia_hooks/hook/provider/use_provided.dart';

NavigatorState useScopedNavigator() => useProvided<ScopedNavigatorState>().navigatorKey.currentState!;
