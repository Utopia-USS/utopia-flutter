import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

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