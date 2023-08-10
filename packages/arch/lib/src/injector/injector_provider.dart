import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:injector/injector.dart';
import 'package:provider/single_child_widget.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

T useInjected<T>() => useProvided<Injector>().get<T>();

class InjectorProvider extends SingleChildStatelessWidget {
  final Injector Function() setupInjector;
  final bool resetOnReassemble;

  const InjectorProvider({super.key, super.child, required this.setupInjector, this.resetOnReassemble = true});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return HookStateProvider(child: child, () {
      final initial = useMemoized(setupInjector);
      final current = useRef(initial);

      if(kDebugMode) {
        // Rebuild is guaranteed to happen after reassemble, so useRef is safe.
        useReassemble(() {
          if(resetOnReassemble) current.value = setupInjector();
        });
      }

      return current.value;
    });
  }
}
