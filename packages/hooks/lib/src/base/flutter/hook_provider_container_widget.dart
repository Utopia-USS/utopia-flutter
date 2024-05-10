import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:utopia_hooks/src/base/provider/hook_provider_container.dart';
import 'package:utopia_hooks/src/provider/provider_widget.dart';

mixin HookProviderContainerWidgetMixin on StatefulWidget {
  abstract final Map<Type, Object? Function()> providers;
  abstract final Priority schedulerPriority;
  abstract final Widget child;
}

class HookProviderContainerWidget extends StatefulWidget with HookProviderContainerWidgetMixin {
  @override
  final Map<Type, Object? Function()> providers;
  @override
  final Priority schedulerPriority;
  @override
  final Widget child;

  const HookProviderContainerWidget(
    this.providers, {
    super.key,
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
  late final HookProviderContainer container;
  late Map<Type, Object?> _values;
  var _isFirstBuild = true;

  @protected
  Map<Type, Object Function()> get additionalProviders => {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      container = HookProviderContainer(schedule: _schedule);
      container.initialize({BuildContext: () => context, ...additionalProviders, ...widget.providers});
      _values = {
        for (final type in widget.providers.keys) type: container.getUnsafe(type),
      };
      for (final entry in widget.providers.keys) {
        container.addListenerUnsafe(entry, (value) => setState(() => _values[entry] = value));
      }
      _isFirstBuild = false;
    } else {
      container.refresh(container.getDependents(BuildContext));
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    container.reassemble();
  }

  @override
  void dispose() {
    container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderWidget(Map.of(_values), child: widget.child);

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
    properties.add(DiagnosticableTreeNode(name: "container", value: container, style: null));
  }
}
