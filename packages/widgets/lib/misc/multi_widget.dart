import 'package:flutter/cupertino.dart';

class MultiWidget extends StatelessWidget {
  final List<Widget Function(Widget child)> widgets;

  const MultiWidget(this.widgets);

  @override
  Widget build(BuildContext context) {
    return widgets.reversed.fold<Widget>(SizedBox.shrink(), (child, widget) => widget(child));
  }
}