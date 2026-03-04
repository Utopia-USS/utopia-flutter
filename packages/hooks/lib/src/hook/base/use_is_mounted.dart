import 'package:utopia_hooks/utopia_hooks.dart';

typedef IsMounted = bool Function();

IsMounted useIsMounted() => use(const _IsMountedHook());

class _IsMountedHook extends Hook<IsMounted> {
  const _IsMountedHook() : super(debugLabel: 'useIsMounted()');

  @override
  HookState<IsMounted, Hook<IsMounted>> createState() => _IsMountedHookState();
}

class _IsMountedHookState extends HookState<IsMounted, _IsMountedHook> {
  bool _isMounted() => mounted;

  @override
  IsMounted build() => _isMounted;
}
