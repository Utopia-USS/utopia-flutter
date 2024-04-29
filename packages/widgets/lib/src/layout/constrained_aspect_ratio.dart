import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ConstrainedAspectRatio extends SingleChildRenderObjectWidget {
  final double min, max;
  final Alignment? alignment;

  const ConstrainedAspectRatio({super.key, this.min = 0, this.max = double.infinity, this.alignment, super.child})
      : assert(min >= 0),
        assert(min <= max);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderConstrainedAspectRatio(range: (min: min, max: max), alignment: alignment);

  @override
  void updateRenderObject(BuildContext context, _RenderConstrainedAspectRatio renderObject) => renderObject
    ..range = (min: min, max: max)
    ..alignment = alignment;
}

typedef _RatioRange = ({double min, double max});

extension on _RatioRange {
  bool get isValid => this.min >= 0 && this.min <= this.max;
}

class _RenderConstrainedAspectRatio extends RenderShiftedBox {
  _RenderConstrainedAspectRatio({required _RatioRange range, Alignment? alignment})
      : assert(range.isValid),
        _range = range,
        _alignment = alignment,
        super(null);

  _RatioRange _range;

  _RatioRange get range => _range;

  set range(_RatioRange range) {
    assert(range.isValid);
    if (_range == range) return;
    _range = range;
    markNeedsLayout();
  }

  Alignment? _alignment;

  Alignment? get alignment => _alignment;

  set alignment(Alignment? value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final width = child?.getMinIntrinsicWidth(height) ?? 0;
    if (height.isInfinite) return width;
    return width.clamp(height * _range.min, height * _range.max);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final width = child?.getMaxIntrinsicWidth(height) ?? double.infinity;
    if (height.isInfinite) return width;
    return width.clamp(height * _range.min, height * _range.max);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final height = child?.getMinIntrinsicHeight(width) ?? 0;
    if (width.isInfinite) return height;
    return height.clamp(width / _range.max, width / _range.min);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final height = child?.getMaxIntrinsicHeight(width) ?? double.infinity;
    if (width.isInfinite) return height;
    return height.clamp(width / _range.max, width / _range.min);
  }

  @override
  @protected
  Size computeDryLayout(BoxConstraints constraints) {
    if(alignment != null) return constraints.biggest;
    return _getChildSize(constraints);
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
    if (child != null) {
      child!.layout(BoxConstraints.tight(_getChildSize(constraints)), parentUsesSize: true);
      _alignChild();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('minimum aspect ratio', _range.min));
    properties.add(DoubleProperty('maximum aspect ratio', _range.max));
  }

  Size _getChildSize(BoxConstraints constraints) {
    assert(constraints.debugAssertIsValid());
    assert(constraints.hasBoundedWidth || constraints.hasBoundedHeight, "Unbounded constraints");

    // ignore: parameter_assignments
    if (alignment != null) constraints = constraints.loosen();
    if (constraints.isTight) return constraints.biggest;
    final sourceRatio = constraints.maxWidth / constraints.maxHeight;

    if (sourceRatio < _range.min) {
      return constraints.constrain(Size(constraints.maxWidth, constraints.maxWidth / _range.min));
    } else if (sourceRatio <= _range.max) {
      return constraints.biggest;
    } else {
      return constraints.constrain(Size(constraints.maxHeight * _range.max, constraints.maxHeight));
    }
  }

  void _alignChild() {
    assert(child != null);
    assert(!child!.debugNeedsLayout);
    assert(child!.hasSize);
    assert(hasSize);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = alignment?.alongOffset(size - child!.size as Offset) ?? Offset.zero;
  }
}
