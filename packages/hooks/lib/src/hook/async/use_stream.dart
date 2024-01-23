import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/base/hook_context.dart';
import 'package:utopia_hooks/src/hook/async/use_async_snapshot_error_handler.dart';

T? useStreamData<T>(
  Stream<T>? stream, {
  T? initialData,
  bool preserveState = true,
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  final snapshot = useStream(stream, initialData: initialData, preserveState: preserveState);
  useAsyncSnapshotErrorHandler(snapshot, onError: onError);
  return snapshot.data;
}

AsyncSnapshot<T> useStream<T>(Stream<T>? stream, {T? initialData, bool preserveState = true}) =>
    use(_StreamHook(stream, initialData: initialData, preserveState: preserveState));

final class _StreamHook<T> extends Hook<AsyncSnapshot<T>> {
  const _StreamHook(
    this.stream, {
    required this.initialData,
    required this.preserveState,
  });

  final Stream<T>? stream;
  final T? initialData;
  final bool preserveState;

  @override
  _StreamHookState<T> createState() => _StreamHookState<T>();
}

final class _StreamHookState<T> extends HookState<AsyncSnapshot<T>, _StreamHook<T>> {
  StreamSubscription<T>? _subscription;
  late AsyncSnapshot<T> _summary = _initial;

  @override
  void init() {
    super.init();
    _subscribe();
  }

  @override
  void didUpdate(_StreamHook<T> oldWidget) {
    super.didUpdate(oldWidget);
    if (oldWidget.stream != hook.stream) {
      if (_subscription != null) {
        _unsubscribe();
        if (hook.preserveState) {
          _summary = _afterDisconnected(_summary);
        } else {
          _summary = _initial;
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
    if (hook.stream != null) {
      _subscription = hook.stream!.listen(
        (data) {
          _summary = _afterData(data);
          context.markNeedsBuild();
        },
        // ignore: avoid_types_on_closure_parameters
        onError: (Object error, StackTrace stackTrace) {
          _summary = _afterError(error, stackTrace);
          context.markNeedsBuild();
        },
        onDone: () {
          _summary = _afterDone(_summary);
          context.markNeedsBuild();
        },
      );
      _summary = _afterConnected(_summary);
    }
  }

  void _unsubscribe() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  @override
  AsyncSnapshot<T> build() => _summary;

  AsyncSnapshot<T> get _initial => hook.initialData == null
      ? AsyncSnapshot<T>.nothing()
      : AsyncSnapshot<T>.withData(ConnectionState.none, hook.initialData as T);

  AsyncSnapshot<T> _afterConnected(AsyncSnapshot<T> current) => current.inState(ConnectionState.waiting);

  AsyncSnapshot<T> _afterData(T data) {
    return AsyncSnapshot<T>.withData(ConnectionState.active, data);
  }

  AsyncSnapshot<T> _afterError(Object error, StackTrace stackTrace) {
    return AsyncSnapshot<T>.withError(
      ConnectionState.active,
      error,
      stackTrace,
    );
  }

  AsyncSnapshot<T> _afterDone(AsyncSnapshot<T> current) => current.inState(ConnectionState.done);

  AsyncSnapshot<T> _afterDisconnected(AsyncSnapshot<T> current) => current.inState(ConnectionState.none);
}
