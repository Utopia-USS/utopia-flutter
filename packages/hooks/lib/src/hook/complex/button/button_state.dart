import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';

class ButtonState {
  final bool loading, enabled;
  final void Function() onTap;

  const ButtonState({required this.onTap, this.loading = false, this.enabled = true});
}

extension ButtonStateSubmitStateX on SubmitState {
  ButtonState toButtonState({required void Function() onTap, bool enabled = true}) =>
      ButtonState(onTap: onTap, loading: inProgress, enabled: enabled);
}

extension ButtonStateX on ButtonState {
  void Function()? get onTapIfEnabled => enabled ? onTap : null;
}

ButtonState useSubmitButtonState(Future<void> Function() action, {bool enabled = true}) {
  final submitState = useSubmitState();

  void onTap() {
    if (submitState.inProgress) return;
    unawaited(submitState.run(action));
  }

  return submitState.toButtonState(onTap: onTap, enabled: enabled);
}
