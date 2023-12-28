import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';

R? useValueChanged<T, R>(T value, R? Function(T oldValue, R? oldResult) valueChange) =>
    use(_ValueChangedHook(value, valueChange));

final class _ValueChangedHook<T, R> extends Hook<R?> {
  const _ValueChangedHook(this.value, this.valueChanged);

  final R? Function(T oldValue, R? oldResult) valueChanged;
  final T value;

  @override
  _ValueChangedHookState<T, R> createState() => _ValueChangedHookState<T, R>();
}

final class _ValueChangedHookState<T, R> extends HookState<R?, _ValueChangedHook<T, R>> {
  R? _result;

  @override
  void didUpdate(_ValueChangedHook<T, R> oldHook) {
    super.didUpdate(oldHook);
    if (hook.value != oldHook.value) {
      _result = hook.valueChanged(oldHook.value, _result);
    }
  }

  @override
  R? build() => _result;
}
