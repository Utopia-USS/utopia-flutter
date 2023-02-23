import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class ConnectivityState implements HasInitialized {
  final ConnectivityResult? result;
  final Future<ConnectivityResult> Function() awaitInitialized;

  const ConnectivityState({required this.result, required this.awaitInitialized});

  @override
  bool get isInitialized => result != null;

  @Deprecated("Use hasConnection")
  bool get isConnected => hasConnection;

  bool get hasConnection => result != ConnectivityResult.none;
}

ConnectivityState useConnectivityState() {
  final state = useAutoComputedState<ConnectivityResult>(
    compute: () async => Connectivity().checkConnectivity(),
    keys: [],
  );

  useStreamSubscription<ConnectivityResult>(
    useMemoized(() => Connectivity().onConnectivityChanged),
    state.updateValue,
  );

  return ConnectivityState(
    result: state.valueOrNull,
    awaitInitialized: () async {
      if (state.valueOrNull != null) return state.valueOrNull!;
      return state.refresh();
    },
  );
}

@Deprecated("Use standalone useConnectivityState hook")
class ConnectivityStateProvider extends HookStateProviderWidget<ConnectivityState> {
  @Deprecated("Use standalone useConnectivityState hook")
  const ConnectivityStateProvider({super.key});

  @override
  ConnectivityState use() => useConnectivityState();
}
