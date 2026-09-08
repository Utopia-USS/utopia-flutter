import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class OverflowTransformBox extends SingleChildRenderObjectWidget {
  const OverflowTransformBox({super.key, this.alignment = Alignment.center, required this.transform, super.child});

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
  // ignore: library_private_types_in_public_api
  void updateRenderObject(BuildContext context, _RenderOverflowTransformBox renderObject) {
    renderObject
      ..alignment = alignment
      ..transform = transform
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderOverflowTransformBox extends RenderAligningShiftedBox {
  _RenderOverflowTransformBox({required BoxConstraintsTransform transform, super.alignment, super.textDirection})
    : _transform = transform;

  BoxConstraintsTransform _transform;

  BoxConstraintsTransform get transform => _transform;

  set transform(BoxConstraintsTransform value) {
    if (_transform == value) return;
    _transform = value;
    markNeedsLayout();
  }

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
