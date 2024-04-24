import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/provider/provider_widget.dart';

final class HookBuilder extends HookWidget {
  final Widget Function(BuildContext context) builder;

  const HookBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context) => builder(context);
}

abstract class HookWidget extends StatefulWidget {
  const HookWidget({super.key});

  Widget build(BuildContext context);

  @override
  @nonVirtual
  State<HookWidget> createState() => _HookWidgetState();
}

class _HookWidgetState extends State<HookWidget>
    with DiagnosticableTreeMixin, HookContextMixin, HookContextStateMixin<HookWidget> {
  @override
  Widget performBuild(BuildContext context) => widget.build(context);
}

mixin HookContextStateMixin<W extends StatefulWidget> on State<W>, DiagnosticableTree, HookContextMixin {
  Widget performBuild(BuildContext context);

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    final result = wrapBuild(() => performBuild(context));
    _schedulePostBuildCallbacks();
    return result;
  }

  @override
  void reassemble() {
    super.reassemble();
    debugMarkWillReassemble();
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
    if(type == BuildContext) return context;
    return context.getUnsafe(type);
  }

  void _schedulePostBuildCallbacks() =>
      SchedulerBinding.instance.addPostFrameCallback((_) => triggerPostBuildCallbacks());

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(_HookContextStateDiagnosticsNode(this));
  }
}

class _HookContextStateDiagnosticsNode extends DiagnosticableTreeNode {
  _HookContextStateDiagnosticsNode(HookContextStateMixin<StatefulWidget> value) : super(value: value, style: null);

  @override
  List<DiagnosticsNode> getProperties() => const [];
}
