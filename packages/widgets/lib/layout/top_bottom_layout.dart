import 'package:flutter/cupertino.dart';
import 'package:utopia_widgets/layout/fill_viewport_scroll_view.dart';

/// 1. If [top] + [bottom] occupies less than available height, they are laid in space between them.
/// 2. Otherwise, the layout is scrollable and there's no space between [top] and [bottom].
///
/// Designed for classical "content on top/buttons on bottom" screen layout
class TopBottomLayout extends StatelessWidget {
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets padding;
  final Widget top;
  final Widget bottom;

  const TopBottomLayout({
    super.key,
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
