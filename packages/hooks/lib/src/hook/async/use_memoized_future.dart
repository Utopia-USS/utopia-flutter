import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/base/hook_keys.dart';
import 'package:utopia_hooks/src/hook/async/use_future.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';

AsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T>? Function() block, {
  T? initialData,
  bool preserveState = true,
  HookKeys keys = hookKeysEmpty,
}) =>
    // ignore: discarded_futures
    useFuture(useMemoized(block, keys), initialData: initialData, preserveState: preserveState);

T? useMemoizedFutureData<T>(
  Future<T>? Function() block, {
  T? initialData,
  bool preserveState = true,
  void Function(Object, StackTrace)? onError,
  HookKeys keys = hookKeysEmpty,
}) =>
    // ignore: discarded_futures
    useFutureData(useMemoized(block, keys), initialData: initialData, preserveState: preserveState, onError: onError);
