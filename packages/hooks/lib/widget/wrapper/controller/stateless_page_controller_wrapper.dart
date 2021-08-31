import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// do not use with user-scrollable PageViews!
class StatelessPageControllerWrapper extends HookWidget {
  final int pageIndex;
  final Function(PageController controller, int index) onTransition;
  final Widget Function(PageController controller) child;

  const StatelessPageControllerWrapper({
    required this.pageIndex,
    required this.onTransition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final controller = usePageController();
    useEffect(() {
      if (controller.hasClients && controller.page != pageIndex) onTransition(controller, pageIndex);
      return null;
    }, [controller.hasClients, pageIndex]);
    return child(controller);
  }
}
