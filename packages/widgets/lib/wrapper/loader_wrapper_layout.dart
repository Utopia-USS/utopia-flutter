import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoaderWrapperLayout extends StatelessWidget {
  final bool isLoaderVisible;
  final SystemUiOverlayStyle loaderUiOverlayStyle;
  final Widget Function(BuildContext context) loaderBuilder;
  final Widget child;

  const LoaderWrapperLayout({
    required this.isLoaderVisible,
    required this.loaderUiOverlayStyle,
    required this.loaderBuilder,
    required this.child,
  });

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoaderVisible,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
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
