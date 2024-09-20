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
  bool _postBuildCallbacksScheduled = false, _isBeforeExtraBuild = false;

  Widget performBuild(BuildContext context);

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    try {
      // In some circumstances, build() can be called multiple times per frame (e.g. when using LayoutBuilder).
      // In such cases triggerPostBuildCallbacks() scheduled by addPostFrameCallback() has not been called yet, so
      // we need to trigger it before this extraneous build.
      // markNeedsBuild() calls are ignored during that time, since the build will happen right after that.
      if (_postBuildCallbacksScheduled) {
        _isBeforeExtraBuild = true;
        triggerPostBuildCallbacks();
        _isBeforeExtraBuild = false;
      }
      return wrapBuild(() => performBuild(context));
    } finally {
      if (!_postBuildCallbacksScheduled) {
        _postBuildCallbacksScheduled = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _postBuildCallbacksScheduled = false;
          triggerPostBuildCallbacks();
        });
      }
    }
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
  void markNeedsBuild() {
    if (!_isBeforeExtraBuild) {
      setState(() {});
    }
  }

  @override
  dynamic getUnsafe(Object key, {bool? watch}) {
    if (key == BuildContext) return context;
    return context.getUnsafe(key, watch: watch);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(_HookContextStateDiagnosticsNode(this));
    properties.add(
      FlagProperty(
        "post-build callbacks dirty",
        value: _postBuildCallbacksScheduled,
        ifTrue: "post-build callbacks dirty",
      ),
    );
    properties.add(FlagProperty("before extra build", value: _isBeforeExtraBuild, ifTrue: "before extra build"));
  }
}

class _HookContextStateDiagnosticsNode extends DiagnosticableTreeNode {
  _HookContextStateDiagnosticsNode(HookContextStateMixin<StatefulWidget> value) : super(value: value, style: null);

  @override
  List<DiagnosticsNode> getProperties() => const [];
}
