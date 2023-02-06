import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/src/hook/misc/use_value_wrapper.dart';

class StatelessTextEditingControllerWrapper extends HookWidget {
  final String value;
  final void Function(String)? onChanged;
  final Widget Function(TextEditingController) child;

  const StatelessTextEditingControllerWrapper({
    super.key,
    required this.value,
    this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: value);
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
