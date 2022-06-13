import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoaderWrapperLayout extends StatelessWidget {
  final bool isLoaderVisible;
  final SystemUiOverlayStyle loaderUiOverlayStyle;
  final Widget Function(BuildContext context) loaderBuilder;
  final Widget child;

  const LoaderWrapperLayout({
    Key? key,
    required this.isLoaderVisible,
    required this.loaderUiOverlayStyle,
    required this.loaderBuilder,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoaderVisible,
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
