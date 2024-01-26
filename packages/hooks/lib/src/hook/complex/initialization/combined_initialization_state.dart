import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/hook/nested/use_map.dart';
import 'package:utopia_hooks/src/misc/has_initialized.dart';

class CombinedInitializationState extends HasInitialized {
  const CombinedInitializationState({required super.isInitialized});
}

CombinedInitializationState useCombinedInitializationState(Set<Type> types) {
  final states = useMap(types, (type) => useProvidedUnsafe(type) as HasInitialized);

  return CombinedInitializationState(isInitialized: HasInitialized.all(states.values));
}
