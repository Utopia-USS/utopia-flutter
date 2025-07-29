import 'package:flutter/widgets.dart';
import 'package:injector/injector.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

T useInjected<T>() => useProvided<Injector>().get();

extension InjectorBuildContextX on BuildContext {
  T inject<T>() => get<Injector>().get<T>();
}
