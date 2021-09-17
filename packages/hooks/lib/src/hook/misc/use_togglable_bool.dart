import 'package:flutter_hooks/flutter_hooks.dart';

class TogglableBoolState {
  final bool value;
  final Function() toggle;

  const TogglableBoolState({
    required this.toggle,
    required this.value,
  });
}

TogglableBoolState useTogglableBool(bool initialValue) {
  final state = useState<bool>(initialValue);

  return TogglableBoolState(
    value: state.value,
    toggle: () => state.value = !state.value,
  );
}
