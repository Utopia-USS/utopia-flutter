import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class OverflowTransformBox extends SingleChildRenderObjectWidget {
  const OverflowTransformBox({
    super.key,
    this.alignment = Alignment.center,
    required this.transform,
    super.child,
  });

  final AlignmentGeometry alignment;

  final BoxConstraintsTransform transform;

  @override
  RenderAligningShiftedBox createRenderObject(BuildContext context) {
    return _RenderOverflowTransformBox(
      alignment: alignment,
      transform: transform,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAligningShiftedBox renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderOverflowTransformBox extends RenderAligningShiftedBox {
  _RenderOverflowTransformBox({
    required this.transform,
    super.alignment,
    super.textDirection,
  });

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
