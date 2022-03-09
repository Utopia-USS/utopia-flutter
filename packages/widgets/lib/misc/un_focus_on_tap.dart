import 'package:flutter/cupertino.dart';

class UnFocusOnTap extends StatelessWidget {
  final Widget child;

  const UnFocusOnTap({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}