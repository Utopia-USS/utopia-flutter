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
  bool _postBuildCallbacksDirty = false, _isDuringExtraBuild = false;

  Widget performBuild(BuildContext context);

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    try {
      // In some circumstances, build() can be called multiple times per frame (e.g. when using LayoutBuilder).
      // In such cases triggerPostBuildCallbacks() scheduled by addPostFrameCallback() has not been called yet, so
      // we need to trigger it during this extraneous build.
      // markNeedsBuild() calls are ignored during that time, since the actual build will happen right after that.
      if (_postBuildCallbacksDirty) {
        try {
          _isDuringExtraBuild = true;
          _postBuildCallbacksDirty = false;
          triggerPostBuildCallbacks();
        } finally {
          _isDuringExtraBuild = false;
        }
      }
      return wrapBuild(() => performBuild(context));
    } finally {
      _postBuildCallbacksDirty = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _postBuildCallbacksDirty = false;
        triggerPostBuildCallbacks();
      });
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
    if (!_isDuringExtraBuild) {
      setState(() {});
    }
  }

  @override
  dynamic getUnsafe(Type type) {
    if (type == BuildContext) return context;
    return context.getUnsafe(type);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(_HookContextStateDiagnosticsNode(this));
    properties.add(
      FlagProperty("post-build callbacks dirty", value: _postBuildCallbacksDirty, ifTrue: "post-build callbacks dirty"),
    );
    properties.add(FlagProperty("during extra build", value: _isDuringExtraBuild, ifTrue: "during extra build"));
  }
}

class _HookContextStateDiagnosticsNode extends DiagnosticableTreeNode {
  _HookContextStateDiagnosticsNode(HookContextStateMixin<StatefulWidget> value) : super(value: value, style: null);

  @override
  List<DiagnosticsNode> getProperties() => const [];
}
