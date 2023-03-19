import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/src/hook/misc/use_value_wrapper.dart';
import 'package:utopia_utils/utopia_utils.dart';

class StatelessTextEditingControllerWrapper extends HookWidget {
  final String value;
  final void Function(String)? onChanged;
  final TextEditingController Function({String? text}) controllerProvider;
  final Widget Function(TextEditingController) child;

  const StatelessTextEditingControllerWrapper({
    super.key,
    required this.value,
    this.onChanged,
    this.controllerProvider = TextEditingController.new,
    required this.child,
  });

  StatelessTextEditingControllerWrapper.mutableValue(
    MutableValue<String> value, {
    super.key,
    this.controllerProvider = TextEditingController.new,
    required this.child,
  }) : value = value.value, onChanged = value.set;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(controllerProvider);
    useEffect(() => controller.dispose, []);

    final wrappedValue = useValueWrapper(value);
    useEffect(() {
      void listener() {
        if (controller.text != wrappedValue()) onChanged?.call(controller.text);
      }

      controller.addListener(listener);
      return () {
        try {
          controller.removeListener(listener);
        } catch (_) {
          // ignore errors during dispose
        }
      };
    }, []);
    if (controller.text != value) Future.microtask(() => controller.text = value);

    return child(controller);
  }
}
