import 'package:meta/meta.dart';
import 'package:utopia_hooks/src/base/hook.dart';

abstract interface class HookContext {
  static final stack = HookContextStack();

  bool get mounted;

  T use<T>(Hook<T> hook);

  T get<T>();

  void markNeedsBuild();

  void addPostBuildCallback(void Function() callback);
}

class HookContextStack {
  final List<HookContext> _stack = [];

  HookContext? get current => _stack.lastOrNull;

  T wrap<T>(HookContext context, T Function() callback) {
    _stack.add(context);
    try {
      return callback();
    } finally {
      _stack.removeLast();
    }
  }
}

T use<T>(Hook<T> hook) => HookContext.stack.current!.use(hook);

@optionalTypeArgs
T useContext<T extends HookContext>() => HookContext.stack.current! as T;

T useProvided<T>() => useContext().get<T>();
