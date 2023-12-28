import 'package:utopia_hooks/src/hook/base/use_state.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

T? usePreviousIfNull<T>(T? value) {
  final state = useState(value, listen: false);
  if(value != null) state.value = value;
  return state.value;
}
