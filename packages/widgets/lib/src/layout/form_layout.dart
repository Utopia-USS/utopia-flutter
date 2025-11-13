import 'package:flutter/cupertino.dart';

/// Scrollable layout with fixed content on the bottom.
///
/// This is designed for long screens (usually forms with multiple fields - hence `FormLayout`) with some
/// always-visible, fixed content on the bottom (usually a submit button).
/// The [content] and [bottom] widgets are separated with a semi-transparent fade-bar, so it looks like [bottom] is laid
/// out "above" the [content].
/// When [content] scrolls to the end, fade-bar disappears so that last part of it is fully visible.
class FormLayout extends StatefulWidget {
  final Color backgroundColor;
  final double fadeBarHeight;
  final Duration fadeDuration;
  final Widget content;
  final Widget bottom;

  // TODO remove in next breaking release
  @Deprecated("Use FormLayout.simple")
  FormLayout({
    super.key,
    required this.backgroundColor,
    this.fadeBarHeight = 16,
    this.fadeDuration = const Duration(milliseconds: 100),
    required Widget content,
    required this.bottom,
  }) : content = SingleChildScrollView(child: content);

  FormLayout.simple({
    super.key,
    required this.backgroundColor,
    this.fadeBarHeight = 16,
    this.fadeDuration = const Duration(milliseconds: 100),
    required Widget content,
    required this.bottom,
  }) : content = SingleChildScrollView(child: content);

  const FormLayout.raw({
    super.key,
    required this.backgroundColor,
    this.fadeBarHeight = 16,
    this.fadeDuration = const Duration(milliseconds: 100),
    required this.content,
    required this.bottom,
  });

  @override
  State<FormLayout> createState() => _FormLayoutState();
}

class _FormLayoutState extends State<FormLayout> {
  bool isFadeBarVisible = true;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildContent(),
                Align(alignment: Alignment.bottomCenter, child: _buildFadeBar()),
              ],
            ),
          ),
          widget.bottom,
        ],
      ),
    );
  }

  Widget _buildFadeBar() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isFadeBarVisible ? 1 : 0,
        duration: widget.fadeDuration,
        child: Container(
          height: widget.fadeBarHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [widget.backgroundColor.withValues(alpha: 0), widget.backgroundColor],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final current = notification.metrics.pixels;
        final max = notification.metrics.maxScrollExtent - widget.fadeBarHeight;
        if (!isFadeBarVisible && current < max) setState(() => isFadeBarVisible = true);
        if (isFadeBarVisible && current >= max) setState(() => isFadeBarVisible = false);
        return false;
      },
      child: widget.content,
    );
  }
}
