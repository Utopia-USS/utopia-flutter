import 'package:flutter/cupertino.dart';

class FillViewportScrollView extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollPhysics? physics;

  const FillViewportScrollView({
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, viewportConstrains) {
      return SingleChildScrollView(
        physics: physics,
        scrollDirection: scrollDirection,
        reverse: reverse,
        child: ConstrainedBox(
          constraints: scrollDirection == Axis.vertical
              ? BoxConstraints(minHeight: viewportConstrains.maxHeight)
              : BoxConstraints(minWidth: viewportConstrains.maxWidth),
          child: scrollDirection == Axis.vertical ? IntrinsicHeight(child: child) : IntrinsicWidth(child: child),
        ),
      );
    });
  }
}
