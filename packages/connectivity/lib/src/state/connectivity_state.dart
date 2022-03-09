import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class ConnectivityState {
  final ConnectivityResult? result;
  final Future<ConnectivityResult> Function() awaitInitialized;

  const ConnectivityState({required this.result, required this.awaitInitialized});

  bool get isInitialized => result != null;

  bool get isConnected => result != ConnectivityResult.none;
}

class ConnectivityStateProvider extends HookStateProviderWidget<ConnectivityState> {
  const ConnectivityStateProvider({Key? key}) : super(key: key);

  @override
  ConnectivityState use() {
    final state = useAutoComputedState<ConnectivityResult>(
      compute: () => Connectivity().checkConnectivity(),
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
        return await state.tryRefresh();
      },
    );
  }
}
