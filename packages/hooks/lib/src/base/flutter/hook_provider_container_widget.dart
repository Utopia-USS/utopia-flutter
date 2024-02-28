import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:utopia_hooks/src/base/provider/hook_provider_container.dart';
import 'package:utopia_hooks/src/provider/provider_widget.dart';

class HookProviderContainerWidget extends StatefulWidget {
  final Map<Type, Object? Function()> providers;
  final Widget child;
  final Priority schedulerPriority;

  const HookProviderContainerWidget(
    this.providers, {
    required this.child,
    this.schedulerPriority = Priority.animation,
    super.key,
  });

  @override
  State<HookProviderContainerWidget> createState() => _HookProviderContainerWidgetState();
}

class _HookProviderContainerWidgetState extends State<HookProviderContainerWidget> {
  late final HookProviderContainer _container;
  late Map<Type, Object?> _values;
  var _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _container = HookProviderContainer(schedule: _schedule);
    _container.initialize({BuildContext: () => context, ...widget.providers});
    _values = {
      for (final type in widget.providers.keys) type: _container.getUnsafe(type),
    };
    for (final entry in widget.providers.keys) {
      _container.addListenerUnsafe(entry, (value) => setState(() => _values[entry] = value));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _isFirstBuild = false;
    } else {
      _container.refresh(_container.getDependents(BuildContext));
    }
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderWidget(Map.of(_values), child: widget.child);

  void _schedule(void Function() block) {
    unawaited(SchedulerBinding.instance
        .scheduleTask(block, widget.schedulerPriority, debugLabel: 'HookProviderContainer refresh'));
  }
}
