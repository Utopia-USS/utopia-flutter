import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/flutter/hook_widget.dart';

class HookCoordinator<T> extends HookWidget {
  final T Function() use;
  final Widget Function(T) builder;

  const HookCoordinator({
    super.key,
    required this.use,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(use());
}
