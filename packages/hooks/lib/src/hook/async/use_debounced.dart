import 'dart:async';

import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';
import 'package:utopia_hooks/src/hook/base/use_state.dart';

T useDebounced<T>(T value, {required Duration duration}) {
  final valueState = useState(value);
  final isMounted = useIsMounted();

  useEffect(() {
    final timer = Timer(duration, () {
      if(isMounted()) valueState.value = value;
    });
    return timer.cancel;
  }, [value]);

  return valueState.value;
}
