import 'package:test/test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class _State {
  final ComputedState<int> xd;

  const _State(this.xd);
}

void main() {
  test("SimpleHookProviderContainer", () async {
    final container = SimpleHookProviderContainer({
      _State: () => _State(useAutoComputedState(() async => 1)),
    });

    expect(container.get<_State>().xd.valueOrNull, null);
    await container.waitUntil<_State>((it) => it.xd.valueOrNull == 1);
  });
}
