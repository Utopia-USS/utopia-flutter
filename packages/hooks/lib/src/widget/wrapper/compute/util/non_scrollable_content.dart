import 'package:flutter/widgets.dart';

class NonScrollableContent extends StatelessWidget {
  final Widget child;

  const NonScrollableContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        SingleChildScrollView(physics: AlwaysScrollableScrollPhysics()),
      ],
    );
  }
}