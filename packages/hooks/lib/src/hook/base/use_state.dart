import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

StateHookState<T> useState<T>(T initialValue, {bool listen = true}) => use(_StateHook(initialValue, listen: listen));

@Deprecated('Use useState(listen: false) instead')
StateHookState<T> useRef<T>(T initialValue) => use(_StateHook(initialValue, listen: false));

abstract class StateHookState<T> implements ListenableMutableValue<T> {
  bool get mounted;
}

extension StateHookStateX<T> on StateHookState<T> {
  bool setIfMounted(T value) {
    if (mounted) this.value = value;
    return mounted;
  }
}

final class _StateHook<T> extends Hook<StateHookState<T>> {
  final T initialValue;
  final bool listen;

  const _StateHook(this.initialValue, {required this.listen})
      : super(debugLabel: "useState<$T>(${!listen ? "listen: false" : ""})");

  @override
  _StateHookState<T> createState() => _StateHookState<T>(initialValue);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('initialValue', initialValue));
  }
}

final class _StateHookState<T> extends HookState<StateHookState<T>, _StateHook<T>>
    with ChangeNotifier
    implements StateHookState<T> {
  T _value;

  _StateHookState(this._value);

  @override
  StateHookState<T> build() => this;

  @override
  T get value => _value;

  @override
  set value(T value) {
    if (value == _value) return;
    assert(() {
      if (!mounted) {
        throw FlutterError.fromParts([
          ErrorSummary("Tried to set StateHook's value after it's been unmounted"),
          ErrorHint("Use state.setIfMounted() to check if state is mounted before setting its value"),
          DiagnosticableNode(name: "hook", value: this, style: null),
        ]);
      }
      return true;
    }());
    _value = value;
    notifyListeners();
    if (hook.listen) context.markNeedsBuild();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('value', _value));
  }
}
