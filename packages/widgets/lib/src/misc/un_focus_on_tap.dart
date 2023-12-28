import 'package:flutter/cupertino.dart';

class UnFocusOnTap extends StatelessWidget {
  final Widget child;

  const UnFocusOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
