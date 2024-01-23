import 'package:flutter/cupertino.dart';

/// ScrollView which forces child to be at least as big as the viewport in the main axis direction.
///
/// See https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html#:~:text=SingleChildScrollView.1%20mysample-,Expanding,-content%20to%20fit
class FillViewportScrollView extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollPhysics? physics;

  const FillViewportScrollView({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewportConstrains) {
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
      },
    );
  }
}
