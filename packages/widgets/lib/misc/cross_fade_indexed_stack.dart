import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/utopia_utils.dart';

/// Like `IndexedStack`, but pages fade through during transitions and can be lazy-initialized.
///
/// Designed for usage as content of screen controlled by `BottomNavigationBar`.
class CrossFadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;
  final bool lazy;

  const CrossFadeIndexedStack({
    super.key,
    this.curve = Curves.linear,
    required this.duration,
    required this.index,
    required this.children,
    this.lazy = false,
  });

  @override
  State<CrossFadeIndexedStack> createState() => _CrossFadeIndexedStackState();
}

class _CrossFadeIndexedStackState extends State<CrossFadeIndexedStack> {
  late final _usedIndexes = {widget.index};

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          IgnorePointer(
            ignoring: widget.index != i,
            child: AnimatedOpacity(
              opacity: widget.index == i ? 1 : 0,
              duration: widget.duration,
              curve: widget.curve,
              child: widget.children[i].takeIf((it) => !widget.lazy || _usedIndexes.contains(i)),
            ),
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(CrossFadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.children.length == oldWidget.children.length, "Changing the number of children is not supported");
    _usedIndexes.add(widget.index);
  }
}
