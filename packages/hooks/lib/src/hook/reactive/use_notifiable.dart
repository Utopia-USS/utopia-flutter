import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/misc/notifiable.dart';

ListenableNotifiable useNotifiable() => use(const _NotifiableHook());

ListenableNotifiableValue<T> useNotifiableValue<T>(T Function() create) => use(_NotifiableValueHook(create));

class _NotifiableHook extends Hook<ListenableNotifiable> {
  const _NotifiableHook() : super(debugLabel: 'useNotifiable()');

  @override
  _NotifiableHookState createState() => _NotifiableHookState();
}

class _NotifiableValueHook<T> extends Hook<ListenableNotifiableValue<T>> {
  final T Function() create;

  const _NotifiableValueHook(this.create) : super(debugLabel: 'useNotifiableValue<T>()');

  @override
  _NotifiableValueHookState<T> createState() => _NotifiableValueHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('create', create, level: DiagnosticLevel.debug));
  }
}

class _NotifiableHookState extends _ListenableNotifiableHookState<ListenableNotifiable, _NotifiableHook> {
  @override
  ListenableNotifiable build() => this;
}

class _NotifiableValueHookState<T>
    extends _ListenableNotifiableHookState<ListenableNotifiableValue<T>, _NotifiableValueHook<T>>
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

abstract class _ListenableNotifiableHookState<T, H extends Hook<T>> extends HookState<T, H>
    with ChangeNotifier
    implements ListenableNotifiable {
  @override
  void notify() {
    super.notifyListeners();
    context.markNeedsBuild();
  }
}
