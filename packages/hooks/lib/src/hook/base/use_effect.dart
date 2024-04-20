import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';

typedef EffectHookDispose = dynamic;

void useEffect(EffectHookDispose Function() effect, [HookKeys keys = const []]) =>
    use(_EffectHook(effect, immediate: false, keys: keys));

void useImmediateEffect(EffectHookDispose Function() effect, [HookKeys keys = const []]) =>
    use(_EffectHook(effect, immediate: true, keys: keys));

final class _EffectHook extends KeyedHook<void> {
  final bool immediate;
  final EffectHookDispose Function() effect;

  const _EffectHook(this.effect, {required this.immediate, required super.keys})
      : super(debugLabel: "use${immediate ? 'Immediate' : ''}Effect()");

  @override
  _EffectHookState createState() => _EffectHookState();
}

final class _EffectHookState extends KeyedHookState<void, _EffectHook> {
  EffectHookDispose _dispose;

  @override
  void init() {
    super.init();
    _schedule();
  }

  @override
  void didUpdateKeys() {
    super.didUpdateKeys();
    _schedule();
  }

  @override
  void dispose() {
    _callDispose();
    super.dispose();
  }

  @override
  void build() {}

  void _schedule() {
    if (hook.immediate) {
      _execute();
    } else {
      context.addPostBuildCallback(_execute);
    }
  }

  void _execute([bool init = true]) {
    _callDispose();
    if (init) _dispose = hook.effect();
  }

  void _callDispose() {
    if (_dispose is void Function()) {
      (_dispose as void Function())();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty("dispose callback", _dispose, ifPresent: "has dispose callback"));
  }
}
