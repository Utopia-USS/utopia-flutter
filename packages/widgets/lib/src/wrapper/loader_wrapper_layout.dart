import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoaderWrapperLayout extends StatelessWidget {
  final bool isLoaderVisible;
  final SystemUiOverlayStyle loaderUiOverlayStyle;
  final Widget Function(BuildContext context) loaderBuilder;
  final Widget child;

  const LoaderWrapperLayout({
    super.key,
    required this.isLoaderVisible,
    required this.loaderUiOverlayStyle,
    required this.loaderBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoaderVisible,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(ignoring: isLoaderVisible, child: child),
          if (isLoaderVisible)
            BlockSemantics(
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: loaderUiOverlayStyle,
                child: loaderBuilder(context),
              ),
            ),
        ],
      ),
    );
  }
}
