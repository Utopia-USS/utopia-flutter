import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:utopia_hooks/src/base/provider/hook_provider_container.dart';
import 'package:utopia_hooks/src/provider/provider_widget.dart';

mixin HookProviderContainerWidgetMixin on StatefulWidget {
  abstract final Map<Type, Object? Function()> providers;
  abstract final bool alwaysNotifyDependents;
  abstract final Priority schedulerPriority;
  abstract final Widget child;
}

class HookProviderContainerWidget extends StatefulWidget with HookProviderContainerWidgetMixin {
  @override
  final Map<Type, Object? Function()> providers;
  @override
  final bool alwaysNotifyDependents;
  @override
  final Priority schedulerPriority;
  @override
  final Widget child;

  const HookProviderContainerWidget(
    this.providers, {
    super.key,
    this.alwaysNotifyDependents = true,
    this.schedulerPriority = Priority.animation,
    required this.child,
  });

  @override
  State<HookProviderContainerWidget> createState() => _HookProviderContainerWidgetState();
}

class _HookProviderContainerWidgetState extends State<HookProviderContainerWidget>
    with DiagnosticableTreeMixin, HookProviderContainerWidgetStateMixin {}

mixin HookProviderContainerWidgetStateMixin<W extends HookProviderContainerWidgetMixin>
    on State<W>, DiagnosticableTreeMixin {
  @protected
  HookProviderContainer? container;
  Map<Object, Object?>? _values;
  var _isFirstBuild = true;

  @protected
  Map<Type, Object Function()> get additionalProviders => {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      container = HookProviderContainer(schedule: _schedule, alwaysNotifyDependents: widget.alwaysNotifyDependents);
      container!.initialize({BuildContext: () => context, ...additionalProviders, ...widget.providers});
      _values = {
        for (final type in widget.providers.keys) type: container!.getUnsafe(type),
      };
      for (final entry in widget.providers.keys) {
        container!.addListenerUnsafe(entry, (value) => setState(() => _values![entry] = value));
      }
      _isFirstBuild = false;
    } else {
      container!.refresh(container!.getDependents(BuildContext));
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    container!.reassemble();
  }

  @override
  void dispose() {
    container!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderWidget({...?_values}, child: widget.child);

  void _schedule(void Function() block) {
    unawaited(
      SchedulerBinding.instance
          .scheduleTask(block, widget.schedulerPriority, debugLabel: 'HookProviderContainer refresh'),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty("first build", value: _isFirstBuild, ifTrue: "first build", level: DiagnosticLevel.debug),
    );
    if (container != null) properties.add(DiagnosticableTreeNode(name: "container", value: container!, style: null));
    if (_values != null) {
      properties.add(
        DiagnosticsBlock(
          name: "values",
          properties: [for (final entry in _values!.entries) DiagnosticsProperty(entry.key.toString(), entry.value)],
        ),
      );
    }
  }
}
