import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Dialog that switches between two presentations depending on how much width it is given.
///
/// * Below [fullscreenBreakpoint] the content takes over everything it is given - the fullscreen page that users of
///   small screens expect from a modal flow.
/// * At or above it, the content becomes a centered, rounded card of at most [maxWidth] x [maxHeight].
///
/// There is exactly one breakpoint - there is no separate "tablet" tier. A tablet is either wide enough for the card
/// or it is not.
///
/// The resolved mode is handed to [builder] and, at the same time, published to the whole subtree, so that descendants
/// can adapt without having a flag threaded through their constructors - see [isFullscreenOf]. `DialogActions` is the
/// main consumer of that.
///
/// The widget only decides on presentation; it does not push a route by itself. Use [AdaptiveDialog.show] for that.
class AdaptiveDialog extends StatelessWidget {
  /// Width under which the dialog is laid out fullscreen. Used as the default of [fullscreenBreakpoint] here and of
  /// the identically named parameter of `FormDialog` and `DialogActions`, so that the three stay in sync.
  static const double defaultFullscreenBreakpoint = 600;

  /// Default of [maxWidth].
  static const double defaultMaxWidth = 1000;

  /// Default of [maxHeight].
  static const double defaultMaxHeight = 800;

  /// Default of [borderRadius].
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(16));

  /// Default of [padding].
  static const EdgeInsets defaultPadding = EdgeInsets.all(16);

  /// Builds the dialog content for the resolved mode.
  ///
  /// `isFullscreen` is the same value that [isFullscreenOf] reports to the subtree; it is passed here as well so that
  /// the direct child does not have to insert a [Builder] just to read it.
  // ignore: avoid_positional_boolean_parameters, positional here to match the shape of Flutter's own builders
  final Widget Function(BuildContext context, bool isFullscreen) builder;

  /// Width at which the layout flips: `constraints.maxWidth < fullscreenBreakpoint` is the fullscreen mode.
  ///
  /// The comparison is made against the constraints the dialog itself receives, not against the physical screen size,
  /// so a dialog placed inside an already narrow area correctly falls back to its fullscreen layout.
  final double fullscreenBreakpoint;

  /// Maximum width of the card. Ignored in fullscreen mode.
  final double maxWidth;

  /// Maximum height of the card. Ignored in fullscreen mode.
  ///
  /// Note that the card is always given a bounded height, which is what allows the content to use flex children
  /// (`Expanded`/`Flexible`) even though the card itself is centered in an otherwise unbounded space.
  final double maxHeight;

  /// Padding between the card and the edges of [maxWidth] x [maxHeight]. Ignored in fullscreen mode.
  final EdgeInsetsGeometry padding;

  /// Corner radius of the card, applied both to its [Material] and to the [ClipRRect] clipping its content.
  /// Ignored in fullscreen mode.
  final BorderRadius borderRadius;

  /// Surface color of the dialog. When `null`, the ambient theme decides - see [resolveBackgroundColor].
  ///
  /// It is painted in both modes: a fullscreen dialog has to be opaque, otherwise the app stays visible behind it.
  final Color? backgroundColor;

  /// Creates an adaptive dialog. See the class documentation for the two layouts it produces.
  const AdaptiveDialog({
    super.key,
    required this.builder,
    this.fullscreenBreakpoint = defaultFullscreenBreakpoint,
    this.maxWidth = defaultMaxWidth,
    this.maxHeight = defaultMaxHeight,
    this.padding = defaultPadding,
    this.borderRadius = defaultBorderRadius,
    this.backgroundColor,
  });

  /// Whether the closest enclosing [AdaptiveDialog] is laid out fullscreen, or `null` when there is none.
  ///
  /// Use this over [isFullscreenOf] for widgets that also have to work outside of a dialog and can fall back to
  /// something else (`DialogActions` falls back to measuring its own width).
  static bool? maybeIsFullscreenOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AdaptiveDialogScope>()?.isFullscreen;

  /// Whether the closest enclosing [AdaptiveDialog] is laid out fullscreen.
  ///
  /// Asserts when called outside of an [AdaptiveDialog]; in release mode it degrades to `false` (the card layout)
  /// instead of throwing.
  static bool isFullscreenOf(BuildContext context) {
    final isFullscreen = maybeIsFullscreenOf(context);
    assert(isFullscreen != null, "AdaptiveDialog.isFullscreenOf() called outside of an AdaptiveDialog.");
    return isFullscreen ?? false;
  }

  /// Resolves the surface color of a dialog: [backgroundColor] when given, otherwise the ambient
  /// [DialogThemeData.backgroundColor], otherwise [ColorScheme.surface].
  ///
  /// Exposed because widgets built on top of [AdaptiveDialog] occasionally need the very same color for their own
  /// painting - `FormDialog` for instance has to hand it to the fade bar of `FormLayout`.
  static Color resolveBackgroundColor(BuildContext context, Color? backgroundColor) =>
      backgroundColor ?? DialogTheme.of(context).backgroundColor ?? Theme.of(context).colorScheme.surface;

  /// Pushes [dialog] as a modal route through [showDialog], with `useSafeArea` disabled - an adaptive dialog handles
  /// insets itself, and a fullscreen one has to be able to paint into them.
  ///
  /// [dismissible] controls whether tapping the barrier pops the route.
  ///
  /// [barrierColor] is the scrim painted behind the dialog. Defaults to `Colors.black54`, the same value [showDialog]
  /// uses; pass `Colors.transparent` for no scrim at all.
  ///
  /// [barrierBlur] additionally blurs everything behind the dialog by that sigma. Because a [BackdropFilter] can only
  /// blur what is painted below it in the same layer tree, the blur cannot live in the route's barrier - it is
  /// instead stacked below [dialog] inside the route itself, wrapped in an [IgnorePointer] so the real barrier
  /// underneath keeps receiving the taps that [dismissible] depends on. The practical effect is that an already open
  /// dialog underneath reads as visually behind this one, instead of competing with it.
  static Future<T?> show<T>(
    BuildContext context,
    Widget dialog, {
    bool dismissible = true,
    Color? barrierColor,
    double barrierBlur = 0,
  }) {
    final resolvedBarrierColor = barrierColor ?? Colors.black54;
    if (barrierBlur <= 0) {
      return showDialog<T>(
        context: context,
        useSafeArea: false,
        barrierDismissible: dismissible,
        barrierColor: resolvedBarrierColor,
        builder: (_) => dialog,
      );
    }
    return showDialog<T>(
      context: context,
      useSafeArea: false,
      barrierDismissible: dismissible,
      barrierColor: Colors.transparent,
      builder: (_) => Stack(
        // Expand so that [dialog] gets the same tight, full-screen constraints it would get without this stack.
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: barrierBlur, sigmaY: barrierBlur),
                child: ColoredBox(color: resolvedBarrierColor),
              ),
            ),
          ),
          dialog,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isFullscreen = constraints.maxWidth < fullscreenBreakpoint;
        final resolvedBackgroundColor = resolveBackgroundColor(context, backgroundColor);
        // The [Builder] is what puts the builder's context *below* the scope, so that content can read the mode.
        final content = _AdaptiveDialogScope(
          isFullscreen: isFullscreen,
          child: Builder(builder: (context) => builder(context, isFullscreen)),
        );
        if (isFullscreen) {
          // The color is painted outside of the [Material] on purpose - an opaque child of a transparency material
          // would paint over its ink features.
          return ColoredBox(
            color: resolvedBackgroundColor,
            child: Material(type: MaterialType.transparency, child: content),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            child: Padding(
              padding: padding,
              child: Material(
                color: resolvedBackgroundColor,
                borderRadius: borderRadius,
                child: ClipRRect(borderRadius: borderRadius, child: content),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Publishes the mode resolved by an [AdaptiveDialog] to its subtree.
class _AdaptiveDialogScope extends InheritedWidget {
  final bool isFullscreen;

  const _AdaptiveDialogScope({required this.isFullscreen, required super.child});

  @override
  bool updateShouldNotify(_AdaptiveDialogScope oldWidget) => isFullscreen != oldWidget.isFullscreen;
}
