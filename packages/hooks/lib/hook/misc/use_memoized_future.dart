import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T> Function() valueBuilder, {
  required T initialData,
  List<Object?> keys = const [],
}) =>
    useFuture(useMemoized(valueBuilder, keys), initialData: initialData);
