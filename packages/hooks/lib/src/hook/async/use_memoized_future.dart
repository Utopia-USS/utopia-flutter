import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/hook/async/use_future.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';

AsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T> Function() valueBuilder, {
  T? initialData,
  HookKeys keys = const [],
}) =>
    // ignore: discarded_futures
    useFuture(useMemoized(valueBuilder, keys), initialData: initialData);
