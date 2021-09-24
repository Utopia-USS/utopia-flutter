import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void useAppLifecycleStateCallbacks({Function()? onPaused, Function()? onResumed}) {
  final wrappedOnPaused = useValueWrapper(onPaused);
  final wrappedOnResumed = useValueWrapper(onResumed);

  useEffect(() {
    final observer = _Observer(onChanged: (state) {
      return state == AppLifecycleState.paused ? wrappedOnPaused.value?.call() : wrappedOnResumed.value?.call();
    });
    WidgetsBinding.instance!.addObserver(observer);
    return () => WidgetsBinding.instance!.removeObserver(observer);
  }, []);
}

class _Observer extends WidgetsBindingObserver {
  final Function(AppLifecycleState state) onChanged;

  _Observer({required this.onChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChanged(state);
}
