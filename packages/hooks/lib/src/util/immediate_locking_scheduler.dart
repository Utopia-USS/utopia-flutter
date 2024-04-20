import 'package:utopia_hooks/src/base/hook_context_impl.dart';
import 'package:utopia_hooks/src/base/provider/hook_provider_container.dart';

/// An immediate scheduler that prevents reentrant calls.
///
/// This scheduler executes the task synchronously, unless a task is already running.
/// In that case, the task is added to a queue and executed synchronously after the current task finishes.
///
/// See [SimpleHookContext] and [SimpleHookProviderContainer] where this scheduler is used.
class ImmediateLockingScheduler {
  var _isLocked = false;
  final _pending = <void Function()>[];

  void call(void Function() callback) {
    if (_isLocked) {
      _pending.add(callback);
    } else {
      _isLocked = true;
      try {
        callback();
        while (_pending.isNotEmpty) {
          final pendingCallback = _pending.removeAt(0);
          pendingCallback();
        }
      } finally {
        _isLocked = false;
      }
    }
  }
}
