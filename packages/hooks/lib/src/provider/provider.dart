import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/base/flutter/hook_widget.dart';

class RawProvider extends InheritedModel<Type> {
  final Map<Type, Object?> values;

  const RawProvider(this.values, {required super.child, super.key});

  static T of<T>(BuildContext context) => InheritedModel.inheritFrom<RawProvider>(context, aspect: T)!.values[T] as T;

  @override
  bool isSupportedAspect(Object aspect) => aspect is Type && values.containsKey(aspect);

  @override
  bool updateShouldNotifyDependent(RawProvider oldWidget, Set<Type> dependencies) =>
      dependencies.any((it) => values[it] != oldWidget.values[it]);

  @override
  bool updateShouldNotify(RawProvider oldWidget) => values != oldWidget.values;
}

class ValueProvider<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const ValueProvider(this.value, {required this.child, super.key});

  @override
  Widget build(BuildContext context) => RawProvider({T: value}, child: child);
}

class HookProvider<T> extends HookWidget {
  final T Function() use;
  final Widget child;
  
  const HookProvider(this.use, {required this.child, super.key});
  
  @override
  Widget build(BuildContext context) => ValueProvider(use(), child: child);
}

extension ProviderBuildContextExtensions on BuildContext {
  T get<T>() => RawProvider.of<T>(this);
}
