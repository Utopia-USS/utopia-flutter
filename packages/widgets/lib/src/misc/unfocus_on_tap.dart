import 'package:flutter/cupertino.dart';

/// Unfocuses the currently focused node when the user taps anywhere inside [child].
///
/// Typically wrapped around a whole screen so that tapping outside a text field dismisses the keyboard.
class UnfocusOnTap extends StatelessWidget {
  final Widget child;

  const UnfocusOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(excludeFromSemantics: true, onTap: () => FocusScope.of(context).unfocus(), child: child);
  }
}

// TODO remove in next breaking release
@Deprecated("Renamed to UnfocusOnTap")
typedef UnFocusOnTap = UnfocusOnTap;
