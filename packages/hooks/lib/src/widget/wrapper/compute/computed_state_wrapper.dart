import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/flutter/hook_widget.dart';
import 'package:utopia_hooks/src/hook/complex/computed/computed_state.dart';
import 'package:utopia_hooks/src/hook/misc/use_previous_if_null.dart';
import 'package:utopia_hooks/src/widget/wrapper/compute/util/non_scrollable_content.dart';

class ComputedStateWrapper<E> extends HookWidget {
  final ComputedState<E> state;
  final Widget Function(BuildContext) inProgressBuilder;
  final Widget Function(BuildContext) failedBuilder;
  final Widget Function(BuildContext, E) builder;
  final bool keepInProgress;

  const ComputedStateWrapper({
    super.key,
    required this.state,
    required this.inProgressBuilder,
    required this.failedBuilder,
    required this.builder,
    this.keepInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = state.valueOrNull;
    final previousValue = usePreviousIfNull(value);
    if (value != null || (keepInProgress && previousValue != null)) return builder(context, value ?? previousValue!);
    return NonScrollableContent(
      child: state.value.maybeWhen(
        failed: (_) => failedBuilder(context),
        orElse: () => inProgressBuilder(context),
      ),
    );
  }
}
