import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/src/base/hook.dart';
import 'package:utopia_hooks/src/hook/async/use_stream.dart';
import 'package:utopia_hooks/src/hook/base/use_memoized.dart';

AsyncSnapshot<T> useMemoizedStream<T>(
  Stream<T>? Function() block, {
  T? initialData,
  bool preserveState = true,
  HookKeys keys = const [],
}) =>
    // ignore: discarded_Streams
    useStream(useMemoized(block, keys), initialData: initialData, preserveState: preserveState);

T? useMemoizedStreamData<T>(
  Stream<T>? Function() block, {
  T? initialData,
  bool preserveState = true,
  void Function(Object, StackTrace)? onError,
  HookKeys keys = const [],
}) =>
    // ignore: discarded_Streams
    useStreamData(useMemoized(block, keys), initialData: initialData, preserveState: preserveState, onError: onError);
