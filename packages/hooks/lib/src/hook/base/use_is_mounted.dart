import 'package:utopia_hooks/src/base/hook_context.dart';

typedef IsMounted = bool Function();

IsMounted useIsMounted() {
  final context = HookContext.current!;
  return () => context.mounted;
}
