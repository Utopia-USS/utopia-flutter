import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/hook/flutter/animation/use_single_ticker_provider.dart';

AnimationController useAnimationController({
  Duration? duration,
  Duration? reverseDuration,
  String? debugLabel,
  double initialValue = 0,
  double lowerBound = 0,
  double upperBound = 1,
  TickerProvider? vsync,
  AnimationBehavior animationBehavior = AnimationBehavior.normal,
}) {
  vsync ??= useSingleTickerProvider();

  return use(
    _AnimationControllerHook(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      initialValue: initialValue,
      lowerBound: lowerBound,
      upperBound: upperBound,
      vsync: vsync,
      animationBehavior: animationBehavior,
    ),
  );
}

extension StaggeredAnimationControllerExtensions on AnimationController {
  Animation<T> staggered<T>({
    required Tween<T> tween,
    double start = 0.0,
    double end = 1.0,
    Curve curve = Curves.linear,
  }) {
    return tween.animate(CurvedAnimation(curve: Interval(start, end, curve: curve), parent: this));
  }
}

final class _AnimationControllerHook extends Hook<AnimationController> {
  final Duration? duration;
  final Duration? reverseDuration;
  final String? debugLabel;
  final double initialValue;
  final double lowerBound;
  final double upperBound;
  final TickerProvider vsync;
  final AnimationBehavior animationBehavior;

  const _AnimationControllerHook({
    this.duration,
    this.reverseDuration,
    this.debugLabel,
    required this.initialValue,
    required this.lowerBound,
    required this.upperBound,
    required this.vsync,
    required this.animationBehavior,
  }) : super(debugLabel: 'useAnimationController()');

  @override
  _AnimationControllerHookState createState() => _AnimationControllerHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('duration', duration));
    properties.add(DiagnosticsProperty('reverse duration', reverseDuration));
    properties.add(StringProperty('debug label', debugLabel));
    properties.add(DoubleProperty('initial value', initialValue, defaultValue: 0));
    properties.add(DoubleProperty('lower bound', lowerBound, defaultValue: 0));
    properties.add(DoubleProperty('upper bound', upperBound, defaultValue: 1));
    properties.add(EnumProperty('behavior', animationBehavior, defaultValue: AnimationBehavior.normal));
  }
}

final class _AnimationControllerHookState extends HookState<AnimationController, _AnimationControllerHook> {
  late final AnimationController _animationController = AnimationController(
    vsync: hook.vsync,
    duration: hook.duration,
    reverseDuration: hook.reverseDuration,
    debugLabel: hook.debugLabel,
    lowerBound: hook.lowerBound,
    upperBound: hook.upperBound,
    animationBehavior: hook.animationBehavior,
    value: hook.initialValue,
  );

  @override
  void didUpdate(_AnimationControllerHook oldHook) {
    super.didUpdate(oldHook);
    if (hook.vsync != oldHook.vsync) {
      _animationController.resync(hook.vsync);
    }
    if (hook.duration != oldHook.duration) {
      _animationController.duration = hook.duration;
    }
    if (hook.reverseDuration != oldHook.reverseDuration) {
      _animationController.reverseDuration = hook.reverseDuration;
    }
  }

  @override
  AnimationController build() => _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
