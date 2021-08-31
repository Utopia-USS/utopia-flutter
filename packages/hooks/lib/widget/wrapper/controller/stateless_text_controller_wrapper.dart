import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StatelessTextEditingControllerWrapper extends HookWidget {
  final String value;
  final Function(String)? onChanged;
  final Widget Function(TextEditingController) child;

  const StatelessTextEditingControllerWrapper({
    required this.value,
    this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    useEffect(() {
      final listener = () {
        if(controller.text != value) onChanged?.call(controller.text);
      };

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
