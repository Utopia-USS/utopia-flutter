import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/utopia_utils.dart';

/// Builds multiple nested widgets.
///
/// Designed for cases when there's many nested but relatively simple widgets. This allows to increase readability by
/// flattening code structure.
/// Also, by using the [MultiWidget.keyed] constructor, allows to conditionally nest widgets *without losing their
/// state*:
/// ```dart
/// MultiWidget.keyed([
///   MapEntry("a", (child) => A(child: child),
///   if(condition) MapEntry("b", (child) => B(child: child),
///   MapEntry("c", (child) => C(child: child),
/// ]);
/// ```
class MultiWidget extends StatefulWidget {
  final List<MapEntry<Object?, Widget Function(Widget child)>> widgets;

  MultiWidget(List<Widget Function(Widget child)> widgets, {Key? key})
      : widgets = widgets.map((it) => MapEntry(null, it)).toList(),
        super(key: key);

  const MultiWidget.keyed(this.widgets, {Key? key}) : super(key: key);

  @override
  State<MultiWidget> createState() => _MultiWidgetState();
}

class _MultiWidgetState extends State<MultiWidget> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return widget.widgets.reversed.fold<Widget>(
      const SizedBox.shrink(),
      (child, widget) => KeyedSubtree(
        key: widget.key?.let((it) => _MultiWidgetKey(parent: _key, value: it)),
        child: widget.value(child),
      ),
    );
  }
}

class _MultiWidgetKey extends GlobalKey {
  final Key parent;
  final Object value;

  const _MultiWidgetKey({required this.parent, required this.value}) : super.constructor();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MultiWidgetKey && runtimeType == other.runtimeType && parent == other.parent && value == other.value;

  @override
  int get hashCode => parent.hashCode ^ value.hashCode;
}
