import 'package:utopia_injector/utopia_injector.dart';

export 'package:utopia_injector/utopia_injector.dart';

@Deprecated("Use Injector.build")
Injector buildInjector(void Function(InjectorRegister register) block) => Injector.build(block);
