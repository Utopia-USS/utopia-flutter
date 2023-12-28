import 'package:utopia_hooks/src/base/hook_context.dart';

typedef IsMounted = bool Function();

IsMounted useIsMounted() {
  final context = useContext();
  return () => context.mounted;
}
