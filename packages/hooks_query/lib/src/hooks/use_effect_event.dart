import 'package:meta/meta.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

@internal
class EffectEvent<T extends Function> {
  EffectEvent._(this._ref);

  final MutableValue<T> _ref;

  T get call => _ref.value;
}

@internal
EffectEvent<T> useEffectEvent<T extends Function>(T callback) {
  return use(_EffectEventHook<T>(callback));
}

class _EffectEventHook<T extends Function> extends Hook<EffectEvent<T>> {
  const _EffectEventHook(this.callback);

  final T callback;

  @override
  _EffectEventHookState<T> createState() => _EffectEventHookState<T>();
}

class _EffectEventHookState<T extends Function>
    extends HookState<EffectEvent<T>, _EffectEventHook<T>> {
  late final MutableValue<T> _ref;

  @override
  void init() {
    super.init();
    _ref = MutableValue(hook.callback);
  }

  @override
  void didUpdate(_EffectEventHook<T> oldHook) {
    super.didUpdate(oldHook);
    _ref.value = hook.callback;
  }

  @override
  EffectEvent<T> build() => EffectEvent<T>._(_ref);
}
