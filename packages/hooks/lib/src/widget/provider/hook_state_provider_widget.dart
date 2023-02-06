import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Combination of `HookWidget` and `Provider`, designed for hook-based global states.
///
/// For simplicity, this widget notifies its consumers after every update (even if oldValue == currentValue).
/// To allow more selective rebuilds, consider overriding [updateShouldNotify].
/// This behaviour may be changed in future releases.
abstract class HookStateProviderWidget<T> extends SingleChildStatelessWidget {
  const HookStateProviderWidget({super.key});

  T use();

  @protected
  bool updateShouldNotify(T old, T current) => true;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return HookBuilder(
      builder: (context) => Provider<T>.value(
        value: use(),
        updateShouldNotify: updateShouldNotify,
        child: child,
      ),
    );
  }
}

class HookStateProvider<T> extends HookStateProviderWidget<T> {
  const HookStateProvider(this.block, {super.key});

  final T Function() block;

  @override
  T use() => block();
}
