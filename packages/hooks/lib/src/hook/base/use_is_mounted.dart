import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/hook/nested/use_debug_group.dart';

typedef IsMounted = bool Function();

IsMounted useIsMounted() {
  return useDebugGroup(debugLabel: "useIsMounted()", () {
    final context = useContext();
    return () => context.mounted;
  });
}
