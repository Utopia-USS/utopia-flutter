import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class OverflowTransformBox extends SingleChildRenderObjectWidget {
  const OverflowTransformBox({
    Key? key,
    this.alignment = Alignment.center,
    required this.transform,
    Widget? child,
  }) : super(key: key, child: child);

  final AlignmentGeometry alignment;

  final BoxConstraintsTransform transform;

  @override
  _RenderOverflowTransformBox createRenderObject(BuildContext context) {
    return _RenderOverflowTransformBox(
      alignment: alignment,
      transform: transform,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderOverflowTransformBox renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderOverflowTransformBox extends RenderAligningShiftedBox {
  _RenderOverflowTransformBox({
    RenderBox? child,
    required this.transform,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection? textDirection,
  }) : super(child: child, alignment: alignment, textDirection: textDirection);

  final BoxConstraintsTransform transform;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    if (child != null) {
      child?.layout(transform(constraints), parentUsesSize: true);
      alignChild();
    }
  }
}