import 'package:flutter/cupertino.dart';
import 'package:injector/injector.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class InjectorProvider extends SingleChildStatelessWidget {
  final Injector Function() setupInjector;

  const InjectorProvider({super.key, required this.setupInjector});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return HookBuilder(
      builder: (context) => Provider<Injector>.value(value: useMemoized(setupInjector), child: child),
    );
  }
}

T useInjected<T>() => useSingleProvided<Injector>().get<T>();
