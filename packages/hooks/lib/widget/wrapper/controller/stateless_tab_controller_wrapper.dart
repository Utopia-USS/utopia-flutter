import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StatelessTabControllerWrapper extends HookWidget {
  final int length;
  final int index;
  final Function(int index) onChanged;
  final Function(TabController) builder;

  const StatelessTabControllerWrapper({
    required this.length,
    required this.index,
    required this.onChanged,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTabController(initialLength: length);

    useEffect(() {
      final listener = () => onChanged(controller.index);
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, []);

    useEffect(() {
      if (index != controller.index) controller.animateTo(index);
    }, [index]);

    return builder(controller);
  }
}
