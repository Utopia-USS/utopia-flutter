import 'package:injector/injector.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

T useInjected<T>() => useProvided<Injector>().get();
