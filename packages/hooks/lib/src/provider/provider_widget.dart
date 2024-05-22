import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  bool updateShouldNotify(ProviderWidget oldWidget) => !mapEquals(values, oldWidget.values);
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

  dynamic getUnsafe(Type type, {bool? watch}) => asProviderContext().getUnsafe(type, watch: watch);

  T get<T>({bool? watch}) => asProviderContext().get<T>(watch: watch);

  T? getOrNull<T>({bool? watch}) => asProviderContext().getOrNull<T>(watch: watch);
}

class _ProviderBuildContext implements ProviderContext {
  final BuildContext context;

  const _ProviderBuildContext(this.context);

  @override
  dynamic getUnsafe(Type type, {bool? watch}) {
    final element = _findElement(type);
    if (element == null) return ProviderContext.valueNotFound;
    // No way to efficiently guess whether we should watch or not, so falling back to true.
    if (watch ?? true) context.dependOnInheritedElement(element, aspect: type);
    return (element.widget as ProviderWidget).values[type];
  }

  InheritedModelElement<Type>? _findElement(Type type) {
    var currentContext = context;
    while (true) {
      final element =
          currentContext.getElementForInheritedWidgetOfExactType<ProviderWidget>() as InheritedModelElement<Type>?;
      if (element == null) return null;
      if ((element.widget as ProviderWidget).isSupportedAspect(type)) return element;
      currentContext = element;
    }
  }
}
