import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utopia_widgets/src/dialog/adaptive_dialog.dart';
import 'package:utopia_widgets/src/layout/form_layout.dart';

/// An [AdaptiveDialog] specialised for forms: a header row on top, scrollable content in the middle and a pinned
/// [bottom] (usually a submit button, or `DialogActions`) that stays visible while the content scrolls under it.
///
/// The middle and bottom part are a [FormLayout], so the content fades out behind [bottom] until it is scrolled to
/// the end.
///
/// Like every [AdaptiveDialog] it is a fullscreen page below [fullscreenBreakpoint] and a floating card above it; the
/// header adapts its default buttons to that (back on fullscreen, close on the card).
class FormDialog extends StatelessWidget {
  static const double _fullscreenContentPadding = 12;
  static const double _cardContentPadding = 24;
  static const double _headerSpacing = 12;

  /// Title of the dialog, rendered with the theme's [TextTheme.titleLarge] unless it brings its own style.
  final Widget title;

  /// Start of the header row. When `null`, a back [IconButton] is shown in fullscreen mode if the dialog is
  /// [dismissible] or [onBackPressed] is set, and in card mode only if [onBackPressed] is set.
  ///
  /// Pass a widget to replace that default, or a [SizedBox.shrink] to suppress it.
  final Widget? leading;

  /// End of the header row. When `null`, a close [IconButton] is shown in card mode if the dialog is [dismissible]
  /// (in fullscreen mode the leading back button already covers that role).
  ///
  /// Pass a widget to replace that default, or a [SizedBox.shrink] to suppress it.
  final Widget? trailing;

  /// Scrollable body of the dialog, as a sliver. Use [FormDialog.simple] to pass a plain box widget instead.
  final Widget sliver;

  /// Pinned content below the scrollable body, kept out of the bottom system inset.
  final Widget bottom;

  /// Whether the dialog can be dismissed by the user, which is what the default header buttons key off.
  ///
  /// This does not by itself make the barrier dismissible - pass the same value to [AdaptiveDialog.show].
  final bool dismissible;

  /// Controller of the internal [CustomScrollView].
  final ScrollController? scrollController;

  /// Overrides what the header's back button does; it pops the dialog by default.
  ///
  /// Setting it also makes the back button appear in card mode, where it is otherwise hidden.
  final VoidCallback? onBackPressed;

  /// See [AdaptiveDialog.fullscreenBreakpoint].
  final double fullscreenBreakpoint;

  /// See [AdaptiveDialog.maxWidth].
  final double maxWidth;

  /// See [AdaptiveDialog.maxHeight].
  final double maxHeight;

  /// See [AdaptiveDialog.padding].
  final EdgeInsetsGeometry padding;

  /// See [AdaptiveDialog.borderRadius].
  final BorderRadius borderRadius;

  /// See [AdaptiveDialog.backgroundColor]. Also used as the background of the internal [FormLayout], so that its fade
  /// bar blends into the dialog.
  final Color? backgroundColor;

  /// Creates a form dialog with a sliver body.
  const FormDialog.raw({
    super.key,
    required this.title,
    required this.sliver,
    required this.bottom,
    this.leading,
    this.trailing,
    this.dismissible = true,
    this.scrollController,
    this.onBackPressed,
    this.fullscreenBreakpoint = AdaptiveDialog.defaultFullscreenBreakpoint,
    this.maxWidth = AdaptiveDialog.defaultMaxWidth,
    this.maxHeight = AdaptiveDialog.defaultMaxHeight,
    this.padding = AdaptiveDialog.defaultPadding,
    this.borderRadius = AdaptiveDialog.defaultBorderRadius,
    this.backgroundColor,
  });

  /// Creates a form dialog whose body is a plain box widget, wrapped in a [SliverToBoxAdapter].
  FormDialog.simple({
    super.key,
    required this.title,
    required Widget content,
    required this.bottom,
    this.leading,
    this.trailing,
    this.dismissible = true,
    this.scrollController,
    this.onBackPressed,
    this.fullscreenBreakpoint = AdaptiveDialog.defaultFullscreenBreakpoint,
    this.maxWidth = AdaptiveDialog.defaultMaxWidth,
    this.maxHeight = AdaptiveDialog.defaultMaxHeight,
    this.padding = AdaptiveDialog.defaultPadding,
    this.borderRadius = AdaptiveDialog.defaultBorderRadius,
    this.backgroundColor,
  }) : sliver = SliverToBoxAdapter(child: content);

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      fullscreenBreakpoint: fullscreenBreakpoint,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      builder: (context, isFullscreen) => Padding(
        // Bottom padding is left to the content, so that the scrollable body can run all the way to the edge.
        padding: EdgeInsets.all(isFullscreen ? _fullscreenContentPadding : _cardContentPadding).copyWith(bottom: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isFullscreen: isFullscreen),
            Flexible(child: _buildForm(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isFullscreen}) {
    final leadingWidget = leading ?? _buildDefaultLeading(context, isFullscreen: isFullscreen);
    final trailingWidget = trailing ?? _buildDefaultTrailing(context, isFullscreen: isFullscreen);
    return SafeArea(
      bottom: false,
      minimum: const EdgeInsets.only(top: _headerSpacing),
      child: Row(
        spacing: _headerSpacing,
        children: [
          ?leadingWidget,
          Expanded(
            child: DefaultTextStyle.merge(style: Theme.of(context).textTheme.titleLarge, child: title),
          ),
          ?trailingWidget,
        ],
      ),
    );
  }

  Widget? _buildDefaultLeading(BuildContext context, {required bool isFullscreen}) {
    final isVisible = isFullscreen ? dismissible || onBackPressed != null : onBackPressed != null;
    if (!isVisible) return null;
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onBackPressed ?? () => unawaited(Navigator.maybePop(context)),
    );
  }

  Widget? _buildDefaultTrailing(BuildContext context, {required bool isFullscreen}) {
    if (isFullscreen || !dismissible) return null;
    return IconButton(icon: const Icon(Icons.close), onPressed: () => unawaited(Navigator.maybePop(context)));
  }

  Widget _buildForm(BuildContext context) {
    return FormLayout.raw(
      backgroundColor: AdaptiveDialog.resolveBackgroundColor(context, backgroundColor),
      content: CustomScrollView(
        controller: scrollController,
        slivers: [SliverPadding(padding: const EdgeInsets.symmetric(vertical: 16), sliver: sliver)],
      ),
      bottom: SafeArea(top: false, minimum: const EdgeInsets.fromLTRB(0, 8, 0, 16), child: bottom),
    );
  }
}
