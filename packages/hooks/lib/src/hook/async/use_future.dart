import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/hook/async/use_async_snapshot_error_handler.dart';

T? useFutureData<T>(
  Future<T?> future, {
  T? initialData,
  bool preserveState = true,
  void Function(Object, StackTrace)? onError,
}) {
  final snapshot = useFuture(future, initialData: initialData, preserveState: preserveState);
  useAsyncSnapshotErrorHandler(snapshot, onError: onError);
  return snapshot.data;
}

AsyncSnapshot<T> useFuture<T>(Future<T>? future, {T? initialData, bool preserveState = true}) =>
    use(_FutureHook(future, initialData: initialData, preserveState: preserveState));

final class _FutureHook<T> extends Hook<AsyncSnapshot<T>> {
  final Future<T>? future;
  final T? initialData;
  final bool preserveState;

  const _FutureHook(this.future, {this.initialData, required this.preserveState});

  @override
  _FutureHookState<T> createState() => _FutureHookState<T>();
}

final class _FutureHookState<T> extends HookState<AsyncSnapshot<T>, _FutureHook<T>> {
  /// An object that identifies the currently active callbacks. Used to avoid
  /// calling `setState` from stale callbacks, e.g. after disposal of this state,
  /// or after widget reconfiguration to a new [Future].
  Object? _activeCallbackIdentity;
  late AsyncSnapshot<T> _snapshot = initial;

  AsyncSnapshot<T> get initial => hook.initialData == null
      ? AsyncSnapshot<T>.nothing()
      : AsyncSnapshot<T>.withData(ConnectionState.none, hook.initialData as T);

  @override
  void init() {
    super.init();
    _subscribe();
  }

  @override
  void didUpdate(_FutureHook<T> oldHook) {
    super.didUpdate(oldHook);
    if (oldHook.future != hook.future) {
      if (_activeCallbackIdentity != null) {
        _unsubscribe();
        if (hook.preserveState) {
          _snapshot = _snapshot.inState(ConnectionState.none);
        } else {
          _snapshot = initial;
        }
      }
      _subscribe();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _unsubscribe();
  }

  void _subscribe() {
    if (hook.future != null) {
      final callbackIdentity = Object();
      _activeCallbackIdentity = callbackIdentity;
      // ignore: discarded_futures
      hook.future!.then<void>((data) {
        if (_activeCallbackIdentity == callbackIdentity) {
          _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, data);
          context.markNeedsBuild();
        }
        // ignore: avoid_types_on_closure_parameters
      }, onError: (Object error, StackTrace stackTrace) {
        if (_activeCallbackIdentity == callbackIdentity) {
          _snapshot = AsyncSnapshot<T>.withError(
            ConnectionState.done,
            error,
            stackTrace,
          );
          context.markNeedsBuild();
        }
      });
      _snapshot = _snapshot.inState(ConnectionState.waiting);
    }
  }

  void _unsubscribe() => _activeCallbackIdentity = null;

  @override
  AsyncSnapshot<T> build() => _snapshot;
}
