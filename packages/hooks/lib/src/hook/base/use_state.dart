import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

StateHookState<T> useState<T>(
  T initialValue, {
  bool listen = true,
  HookKeys keys = hookKeysEmpty,
}) =>
    use(_StateHook(initialValue, listen: listen, keys: keys));

StateHookState<T> useStateLazy<T>(
  T Function() initialValueProvider, {
  bool listen = true,
  HookKeys keys = hookKeysEmpty,
}) =>
    use(_LazyStateHook(initialValueProvider, listen: listen, keys: keys));

@Deprecated('Use useState(listen: false) instead')
StateHookState<T> useRef<T>(T initialValue, {HookKeys keys = hookKeysEmpty}) =>
    use(_StateHook(initialValue, listen: false, keys: keys));

abstract class StateHookState<T> implements ListenableMutableValue<T> {
  bool get mounted;
}

extension StateHookStateX<T> on StateHookState<T> {
  bool setIfMounted(T value) {
    if (mounted) this.value = value;
    return mounted;
  }
}

class _StateHook<T> extends _StateHookBase<T> {
  final T initialValue;

  _StateHook(this.initialValue, {required super.listen, required super.keys}) : super(debugName: "useState");

  @override
  T buildInitialValue() => initialValue;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('initialValue', initialValue));
  }
}

class _LazyStateHook<T> extends _StateHookBase<T> {
  final T Function() initialValueProvider;

  _LazyStateHook(this.initialValueProvider, {required super.listen, required super.keys})
      : super(debugName: "useStateLazy");

  @override
  T buildInitialValue() => initialValueProvider();
}

abstract class _StateHookBase<T> extends KeyedHook<StateHookState<T>> {
  final bool listen;

  const _StateHookBase({required this.listen, required super.keys, required String debugName})
      : super(debugLabel: "$debugName<$T>(${!listen ? "listen: false" : ""})");

  T buildInitialValue();

  @override
  _StateHookState<T> createState() => _StateHookState<T>();
}

final class _StateHookState<T> extends KeyedHookState<StateHookState<T>, _StateHookBase<T>>
    with ChangeNotifier
    implements StateHookState<T> {
  late T _value;

  _StateHookState();

  @override
  void init() {
    super.init();
    _value = hook.buildInitialValue();
  }

  @override
  void didUpdateKeys() {
    super.didUpdateKeys();
    _value = hook.buildInitialValue();
    context.addPostBuildCallback(notifyListeners);
  }

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
