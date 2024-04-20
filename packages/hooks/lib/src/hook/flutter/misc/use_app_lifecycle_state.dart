import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

AppLifecycleState useAppLifecycleState({
  void Function()? onPaused,
  void Function()? onResumed,
  void Function()? onHidden,
  void Function()? onInactive,
}) {
  return useDebugGroup(debugLabel: "useAppLifecycleState()", () {
    final wrappedOnPaused = useValueWrapper(onPaused);
    final wrappedOnResumed = useValueWrapper(onResumed);
    final wrappedOnHidden = useValueWrapper(onHidden);
    final wrappedOnInactive = useValueWrapper(onInactive);

    final lifecycleState = useState(WidgetsBinding.instance.lifecycleState!);

    useEffect(() {
      final observer = _Observer(onChanged: (state) {
        if (state == AppLifecycleState.paused) wrappedOnPaused.value?.call();
        if (state == AppLifecycleState.resumed) wrappedOnResumed.value?.call();
        if (state == AppLifecycleState.hidden) wrappedOnHidden.value?.call();
        if (state == AppLifecycleState.inactive) wrappedOnInactive.value?.call();
        lifecycleState.value = state;
      });
      WidgetsBinding.instance.addObserver(observer);
      return () => WidgetsBinding.instance.removeObserver(observer);
    });

    return lifecycleState.value;
  });
}

class _Observer extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state) onChanged;

  _Observer({required this.onChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChanged(state);
}
