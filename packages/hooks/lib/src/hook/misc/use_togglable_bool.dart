import 'package:flutter_hooks/flutter_hooks.dart';

class TogglableBoolState {
  final bool value;
  final void Function() toggle;

  const TogglableBoolState({
    required this.toggle,
    required this.value,
  });
}

@Deprecated("Replace with ValueNotifer and .toggle() extension")
// ignore: avoid_positional_boolean_parameters
TogglableBoolState useTogglableBool(bool initialValue) {
  final state = useState<bool>(initialValue);

  return TogglableBoolState(
    value: state.value,
    toggle: () => state.value = !state.value,
  );
}
