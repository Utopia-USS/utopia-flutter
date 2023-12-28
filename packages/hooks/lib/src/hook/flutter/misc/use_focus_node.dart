import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';

/// Creates an automatically disposed [FocusNode].
///
/// See also:
/// - [FocusNode]
FocusNode useFocusNode({
  String? debugLabel,
  FocusOnKeyCallback? onKey,
  FocusOnKeyEventCallback? onKeyEvent,
  bool skipTraversal = false,
  bool canRequestFocus = true,
  bool descendantsAreFocusable = true,
}) {
  return use(
    _FocusNodeHook(
      debugLabel: debugLabel,
      onKey: onKey,
      onKeyEvent: onKeyEvent,
      skipTraversal: skipTraversal,
      canRequestFocus: canRequestFocus,
      descendantsAreFocusable: descendantsAreFocusable,
    ),
  );
}

final class _FocusNodeHook extends Hook<FocusNode> {
  final String? debugLabel;
  final FocusOnKeyCallback? onKey;
  final FocusOnKeyEventCallback? onKeyEvent;
  final bool skipTraversal;
  final bool canRequestFocus;
  final bool descendantsAreFocusable;

  const _FocusNodeHook({
    this.debugLabel,
    this.onKey,
    this.onKeyEvent,
    required this.skipTraversal,
    required this.canRequestFocus,
    required this.descendantsAreFocusable,
  });

  @override
  _FocusNodeHookState createState() => _FocusNodeHookState();
}

final class _FocusNodeHookState extends HookState<FocusNode, _FocusNodeHook> {
  late final FocusNode _focusNode = FocusNode(
    debugLabel: hook.debugLabel,
    onKey: hook.onKey,
    onKeyEvent: hook.onKeyEvent,
    skipTraversal: hook.skipTraversal,
    canRequestFocus: hook.canRequestFocus,
    descendantsAreFocusable: hook.descendantsAreFocusable,
  );

  @override
  void didUpdate(_FocusNodeHook oldHook) {
    super.didUpdate(oldHook);
    _focusNode
      ..debugLabel = hook.debugLabel
      ..skipTraversal = hook.skipTraversal
      ..canRequestFocus = hook.canRequestFocus
      ..descendantsAreFocusable = hook.descendantsAreFocusable
      ..onKey = hook.onKey
      ..onKeyEvent = hook.onKeyEvent;
  }

  @override
  FocusNode build() => _focusNode;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
