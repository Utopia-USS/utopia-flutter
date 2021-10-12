import 'package:flutter/cupertino.dart';
import 'package:utopia_widgets/layout/fill_viewport_scroll_view.dart';

class TopBottomLayout extends StatelessWidget {
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets padding;
  final Widget top;
  final Widget bottom;

  const TopBottomLayout({
    this.scrollPhysics,
    this.padding = EdgeInsets.zero,
    required this.top,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return FillViewportScrollView(
      physics: scrollPhysics,
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            Expanded(child: top),
            bottom,
          ],
        ),
      ),
    );
  }
}
