import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StatelessTabControllerWrapper extends HookWidget {
  final int length;
  final int index;
  final void Function(int index) onChanged;
  final Widget Function(TabController) builder;

  const StatelessTabControllerWrapper({
    super.key,
    required this.length,
    required this.index,
    required this.onChanged,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTabController(initialLength: length);

    useEffect(() {
      void listener() => onChanged(controller.index);
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, []);

    useEffect(() {
      if (index != controller.index) controller.animateTo(index);
      return null;
    }, [index]);

    return builder(controller);
  }
}
