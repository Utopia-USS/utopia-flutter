import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';

TickerProvider useSingleTickerProvider() => use(const _SingleTickerProviderHook());

final class _SingleTickerProviderHook extends Hook<TickerProvider> {
  const _SingleTickerProviderHook();

  @override
  _TickerProviderHookState createState() => _TickerProviderHookState();
}

final class _TickerProviderHookState extends HookState<TickerProvider, _SingleTickerProviderHook>
    implements TickerProvider {
  Ticker? _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) => _ticker = Ticker(onTick, debugLabel: 'created by $context');

  @override
  TickerProvider build() {
    if (_ticker != null) {
      _ticker!.muted = !TickerMode.of(useProvided());
    }
    return this;
  }
}
