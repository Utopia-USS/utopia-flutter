import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:utopia_arch/utopia_arch.dart';

class ConnectivityState implements HasInitialized {
  final ConnectivityResult? result;
  final Future<ConnectivityResult> Function() awaitInitialized;

  const ConnectivityState({required this.result, required this.awaitInitialized});

  @override
  bool get isInitialized => result != null;

  bool get hasConnection => result != ConnectivityResult.none;
}

ConnectivityState useConnectivityState() {
  final state = useAutoComputedState(() async => Connectivity().checkConnectivity());

  useStreamSubscription(
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
