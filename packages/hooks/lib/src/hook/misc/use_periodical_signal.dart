import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';

Object usePeriodicalSignal({required Duration period, bool enabled = true}) {
  final state = useState(0);

  useEffect(() {
    if (enabled) {
      final timer = Timer.periodic(period, (_) => state.value++);
      return timer.cancel;
    }
    return null;
  }, [enabled]);

  return state.value;
}
