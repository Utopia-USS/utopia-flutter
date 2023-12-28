import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class StatelessTabControllerWrapper extends HookWidget {
  final int length;
  final MutableValue<int> index;
  final void Function(TabController controller, int index)? onTransition;
  final TabController Function({required TickerProvider vsync, required int length}) controllerProvider;
  final Widget Function(TabController) builder;

  const StatelessTabControllerWrapper({
    super.key,
    required this.length,
    required this.index,
    required this.builder,
    this.onTransition,
    this.controllerProvider = TabController.new,
  });

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();
    final controller = useMemoized(() => TabController(vsync: ticker, length: length), [length], (it) => it.dispose());

    final wrappedIndex = useValueWrapper(index);
    useEffect(() {
      void listener() => wrappedIndex().value = controller.index;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    });

    useEffect(() {
      if (index.value != controller.index) {
        if (onTransition != null) {
          onTransition!(controller, index.value);
        } else {
          controller.animateTo(index.value);
        }
      }
      return null;
    }, [index.value]);

    return builder(controller);
  }
}
