import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/base/flutter/hook_widget.dart';
import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';
import 'package:utopia_hooks/src/hook/base/use_value_wrapper.dart';
import 'package:utopia_utils/utopia_utils.dart';

class StatelessPageControllerWrapper extends HookWidget {
  final MutableValue<int> index;
  final void Function(PageController controller, int index)? onTransition;
  final PageController Function({int initialPage}) controllerProvider;
  final Widget Function(PageController controller) builder;

  const StatelessPageControllerWrapper({
    super.key,
    required this.index,
    required this.builder,
    this.onTransition,
    this.controllerProvider = PageController.new,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() => controllerProvider(initialPage: index.value), [], (it) => it.dispose());

    final wrappedIndex = useValueWrapper(index);
    useEffect(() {
      void listener() {
        if (controller.page != null) {
          wrappedIndex().value = controller.page!.round();
        }
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    });

    useEffect(() {
      if (controller.hasClients && controller.page?.round() != index.value) {
        Timer.run(() {
          if (onTransition != null) {
            onTransition!(controller, index.value);
          } else {
            controller.jumpToPage(index.value);
          }
        });
      }
      return null;
    }, [controller.hasClients, index.value]);

    return builder(controller);
  }
}
