import 'dart:async';

import 'package:utopia_hooks/src/hook/base/use_effect.dart';
import 'package:utopia_hooks/src/hook/base/use_is_mounted.dart';

import '../base/use_state.dart';

Object usePeriodicalSignal({required Duration period, bool enabled = true}) {
  final state = useState(0);
  final isMounted = useIsMounted();

  useEffect(() {
    if (enabled) {
      final timer = Timer.periodic(period, (_) {
        if(isMounted()) state.value++;
      });
      return timer.cancel;
    }
    return null;
  }, [enabled]);

  return state.value;
}
