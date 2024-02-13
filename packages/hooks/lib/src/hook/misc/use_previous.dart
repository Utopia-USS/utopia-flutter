import 'package:utopia_hooks/src/hook/base/use_state.dart';

T? usePrevious<T>(T value) {
  final prev = useState<T?>(null, listen: false);
  final prevValue = prev.value;
  prev.value = value;
  return prevValue;
}
