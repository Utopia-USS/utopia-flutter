import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

T useWithSelf<T extends Object>(T Function(Value<T> self) block) {
  final self = useMemoized(MutableValue<T>.late);
  return self.value = block(self);
}
