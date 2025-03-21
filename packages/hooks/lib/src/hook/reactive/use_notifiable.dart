import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/misc/notifiable.dart';

ListenableNotifiable useNotifiable({bool listen = true}) => use(_NotifiableHook(listen: listen));

ListenableNotifiableValue<T> useNotifiableValue<T>(T Function() create, {bool listen = true}) =>
    use(_NotifiableValueHook(create, listen: listen));

class _NotifiableHook extends _BaseNotifiableHook<ListenableNotifiable> {
  const _NotifiableHook({required super.listen})
      : super(debugLabel: 'useNotifiable(${!listen ? "listen: false" : ""})');

  @override
  _NotifiableHookState createState() => _NotifiableHookState();
}

class _NotifiableValueHook<T> extends _BaseNotifiableHook<ListenableNotifiableValue<T>> {
  final T Function() create;

  const _NotifiableValueHook(this.create, {required super.listen})
      : super(debugLabel: 'useNotifiableValue<$T>(${!listen ? "listen: false" : ""})');

  @override
  _NotifiableValueHookState<T> createState() => _NotifiableValueHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('create', create, level: DiagnosticLevel.debug));
  }
}

abstract class _BaseNotifiableHook<T> extends Hook<T> {
  final bool listen;

  const _BaseNotifiableHook({required super.debugLabel, required this.listen});

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty("listen", value: listen, defaultValue: true));
  }
}

class _NotifiableHookState extends _BaseNotifiableHookState<ListenableNotifiable, _NotifiableHook> {
  @override
  ListenableNotifiable build() => this;
}

class _NotifiableValueHookState<T>
    extends _BaseNotifiableHookState<ListenableNotifiableValue<T>, _NotifiableValueHook<T>>
    implements ListenableNotifiableValue<T> {
  @override
  late final T value;

  @override
  void init() {
    super.init();
    value = hook.create();
  }

  @override
  ListenableNotifiableValue<T> build() => this;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('value', value));
  }
}

abstract class _BaseNotifiableHookState<T, H extends _BaseNotifiableHook<T>> extends HookState<T, H>
    with ChangeNotifier
    implements ListenableNotifiable {
  @override
  void notify() {
    super.notifyListeners();
    if (hook.listen) context.markNeedsBuild();
  }
}
