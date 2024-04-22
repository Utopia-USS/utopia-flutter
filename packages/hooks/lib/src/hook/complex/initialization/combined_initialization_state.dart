import 'package:flutter/foundation.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';
import 'package:utopia_hooks/src/misc/has_initialized.dart';

class CombinedInitializationState extends HasInitialized {
  const CombinedInitializationState({required super.isInitialized});
}

CombinedInitializationState useCombinedInitializationState(Set<Type> types) {
  return useDebugGroup(
    debugLabel: "useCombinedInitializationState()",
    debugFillProperties: (builder) => builder.add(IterableProperty("types", types)),
    () {
      final context = useContext();
      final states = types.map((type) => context.getUnsafe(type) as HasInitialized).toList();
      return CombinedInitializationState(isInitialized: HasInitialized.all(states));
    },
  );
}
