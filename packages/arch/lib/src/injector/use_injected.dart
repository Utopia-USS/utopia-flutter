import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_injector/utopia_injector.dart';

T useInjected<T>() => useProvided<Injector>().get();

extension InjectorBuildContextX on BuildContext {
  T inject<T>() => get<Injector>().get<T>();
}
