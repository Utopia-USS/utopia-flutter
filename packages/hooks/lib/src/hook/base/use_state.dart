import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/misc/listenable_value.dart';

ListenableMutableValue<T> useState<T>(T initialValue, {bool listen = true}) =>
    use(_StateHook(initialValue, listen: listen));

@Deprecated('Use useState(listen: false) instead')
ListenableMutableValue<T> useRef<T>(T initialValue) => use(_StateHook(initialValue, listen: false));

final class _StateHook<T> extends Hook<ListenableMutableValue<T>> {
  final T initialValue;
  final bool listen;

  const _StateHook(this.initialValue, {required this.listen});

  @override
  _StateHookState<T> createState() => _StateHookState<T>(initialValue);
}

final class _StateHookState<T> extends HookState<ListenableMutableValue<T>, _StateHook<T>>
    with ChangeNotifier
    implements ListenableMutableValue<T> {
  T _value;

  _StateHookState(this._value);

  @override
  ListenableMutableValue<T> build() => this;

  @override
  T get value => _value;

  @override
  set value(T value) {
    if (value == _value) return;
    _value = value;
    notifyListeners();
    if (hook.listen) context.markNeedsBuild();
  }
}
