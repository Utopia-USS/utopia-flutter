import 'package:flutter/widgets.dart';

class NonScrollableContent extends StatelessWidget {
  final Widget child;

  const NonScrollableContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        const SingleChildScrollView(physics: AlwaysScrollableScrollPhysics()),
      ],
    );
  }
}
