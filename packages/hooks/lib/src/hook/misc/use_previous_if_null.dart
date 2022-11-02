import 'package:utopia_hooks/utopia_hooks.dart';

T? usePreviousIfNull<T extends Object>(T? value) {
  final state = useRef(value);
  if(value != null) state.value = value;
  return state.value;
}