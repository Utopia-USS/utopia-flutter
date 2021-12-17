import 'package:flutter/cupertino.dart';

class FormLayout extends StatefulWidget {
  final Color backgroundColor;
  final double fadeBarHeight;
  final Duration fadeDuration;
  final Widget content;
  final Widget bottom;

  // TODO remove in next breaking release
  @Deprecated("Use FormLayout.simple")
  FormLayout({
    required this.backgroundColor,
    this.fadeBarHeight = 16,
    this.fadeDuration = const Duration(milliseconds: 100),
    required Widget content,
    required this.bottom,
  }) : content = SingleChildScrollView(child: content);

  FormLayout.simple({
    required this.backgroundColor,
    this.fadeBarHeight = 16,
    this.fadeDuration = const Duration(milliseconds: 100),
    required Widget content,
    required this.bottom,
  }) : content = SingleChildScrollView(child: content);

  const FormLayout.raw({
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
    return AnimatedOpacity(
      opacity: isFadeBarVisible ? 1 : 0,
      duration: widget.fadeDuration,
      child: Container(
        height: widget.fadeBarHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [widget.backgroundColor.withOpacity(0), widget.backgroundColor],
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
