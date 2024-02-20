class ImmediateLockingScheduler {
  var _isLocked = false;
  final _pending = <void Function()>[];

  void call(void Function() callback) {
    if (_isLocked) {
      _pending.add(callback);
    } else {
      _isLocked = true;
      callback();
      while (_pending.isNotEmpty) {
        final pendingCallback = _pending.removeAt(0);
        pendingCallback();
      }
      _isLocked = false;
    }
  }
}
