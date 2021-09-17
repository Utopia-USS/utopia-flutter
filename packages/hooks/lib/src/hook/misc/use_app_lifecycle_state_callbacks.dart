import 'package:flutter/cupertino.dart';

void useAppLifecycleStateCallbacks({Function()? onPaused, Function()? onResumed}) {
  WidgetsBinding.instance!.addObserver(
    _Observer(onChanged: (state) => state == AppLifecycleState.paused ? onPaused?.call() : onResumed?.call()),
  );
}

class _Observer extends WidgetsBindingObserver {
  final Function(AppLifecycleState state) onChanged;

  _Observer({required this.onChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChanged(state);
}
