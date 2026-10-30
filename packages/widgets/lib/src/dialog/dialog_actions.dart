import 'package:flutter/widgets.dart';
import 'package:utopia_widgets/src/dialog/adaptive_dialog.dart';

/// Adaptive action button row for the bottom of a dialog (`FormDialog.bottom`) or of a management view.
///
/// Declare [children] in mobile reading order: primary action first, then destructive / secondary ones.
///
/// Layouts:
///   * Fullscreen dialog: vertical [Column], children stretched to full width, in the declared order.
///   * Floating dialog card: horizontal [Row], right-aligned, intrinsic widths, children *reversed* so that the
///     primary action ends up rightmost - the conventional desktop dialog ordering.
///
/// The mode is read from the enclosing [AdaptiveDialog]. Outside of one, the widget measures its own width against
/// [fullscreenBreakpoint] instead - note that this measures the space the actions get, not the space the dialog gets,
/// so inside a narrow card it may well decide "fullscreen".
class DialogActions extends StatelessWidget {
  /// The actions, in mobile reading order (primary first).
  final List<Widget> children;

  /// Gap between two neighbouring actions, vertical or horizontal depending on the resolved layout.
  final double spacing;

  /// Only used when there is no enclosing [AdaptiveDialog] to ask - see the class documentation.
  final double fullscreenBreakpoint;

  /// Creates an adaptive action row. See the class documentation for the two layouts it produces.
  const DialogActions({
    super.key,
    required this.children,
    this.spacing = 8,
    this.fullscreenBreakpoint = AdaptiveDialog.defaultFullscreenBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    final isFullscreen = AdaptiveDialog.maybeIsFullscreenOf(context);
    if (isFullscreen != null) return _buildLayout(isFullscreen: isFullscreen);
    return LayoutBuilder(
      builder: (context, constraints) => _buildLayout(isFullscreen: constraints.maxWidth < fullscreenBreakpoint),
    );
  }

  Widget _buildLayout({required bool isFullscreen}) {
    if (isFullscreen) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing,
        children: children,
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.end, spacing: spacing, children: children.reversed.toList());
  }
}
