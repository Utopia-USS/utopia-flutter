import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/provider/provider_widget.dart';

abstract class HookWidget extends StatefulWidget {
  const HookWidget({super.key});

  Widget build(BuildContext context);

  @override
  State<HookWidget> createState() => _HookWidgetState();
}

class _HookWidgetState extends State<HookWidget> with HookContextMixin {
  @override
  Widget build(BuildContext context) {
    final result = wrapBuild(() => widget.build(context));
    _schedulePostBuildCallbacks();
    return result;
  }

  @override
  void dispose() {
    super.dispose();
    disposeHooks();
  }

  @override
  void markNeedsBuild() => setState(() {});

  @override
  dynamic getUnsafe(Type type) {
    return switch (type) {
      BuildContext => context,
      _ => context.getUnsafe(type),
    };
  }

  void _schedulePostBuildCallbacks() =>
      SchedulerBinding.instance.addPostFrameCallback((_) => triggerPostBuildCallbacks());
}

class HookBuilder extends HookWidget {
  final Widget Function(BuildContext context) builder;

  const HookBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context) => builder(context);
}
