import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/base/flutter/hook_widget.dart';
import 'package:utopia_hooks/src/provider/provider_context.dart';

class ProviderWidget extends InheritedModel<Type> {
  final Map<Type, Object?> values;

  const ProviderWidget(this.values, {required super.child, super.key});

  @override
  bool isSupportedAspect(Object aspect) => aspect is Type && values.containsKey(aspect);

  @override
  bool updateShouldNotifyDependent(ProviderWidget oldWidget, Set<Type> dependencies) =>
      dependencies.any((it) => values[it] != oldWidget.values[it]);

  @override
  bool updateShouldNotify(ProviderWidget oldWidget) => values != oldWidget.values;
}

class ValueProvider<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const ValueProvider(this.value, {required this.child, super.key});

  @override
  Widget build(BuildContext context) => ProviderWidget({T: value}, child: child);
}

class HookProvider<T> extends HookWidget {
  final T Function() use;
  final Widget child;

  const HookProvider(this.use, {required this.child, super.key});

  @override
  Widget build(BuildContext context) => ValueProvider(use(), child: child);
}

extension ProviderBuildContextExtensions on BuildContext {
  ProviderContext asProviderContext() => _ProviderBuildContext(this);

  dynamic getUnsafe(Type type) => asProviderContext().getUnsafe(type);

  T get<T>() => asProviderContext().get<T>();

  T? getOrNull<T>() => asProviderContext().getOrNull<T>();
}

class _ProviderBuildContext implements ProviderContext {
  final BuildContext context;

  const _ProviderBuildContext(this.context);

  @override
  dynamic getUnsafe(Type type) {
    final provider = InheritedModel.inheritFrom<ProviderWidget>(context, aspect: type);
    if (provider == null) throw ProvidedValueNotFoundException(type: type, context: this);
    return provider.values[type];
  }
}
