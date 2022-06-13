import 'package:async/async.dart';
import 'package:equatable/equatable.dart';

abstract class ComputedStateValue<T> {
  const ComputedStateValue._();

  static const ComputedStateValue<Never> notInitialized = ComputedStateValueNotInitialized._();

  const factory ComputedStateValue.inProgress(
    CancelableOperation<T> operation, {
    required ComputedStateValue<T> previous,
  }) = ComputedStateValueInProgress._;

  const factory ComputedStateValue.ready(T value) = ComputedStateValueReady._;

  const factory ComputedStateValue.failed(Object exception) = ComputedStateValueFailed._;

  const factory ComputedStateValue.cleared({required ComputedStateValue<T> previous}) = ComputedStateValueCleared._;

  R maybeWhen<R>({
    R Function()? notInitialized,
    R Function(CancelableOperation<T> operation, ComputedStateValue<T> previous)? inProgress,
    R Function(T value)? ready,
    R Function(Object exception)? failed,
    R Function(ComputedStateValue<T> previous)? cleared,
    required R Function() orElse,
  }) {
    final value = this;
    if (value is ComputedStateValueNotInitialized && notInitialized != null) return notInitialized();
    if (value is ComputedStateValueInProgress<T> && inProgress != null) {
      return inProgress(value.operation, value.previous);
    }
    if (value is ComputedStateValueReady<T> && ready != null) return ready(value.value);
    if (value is ComputedStateValueFailed && failed != null) return failed(value.exception);
    if (value is ComputedStateValueCleared<T> && cleared != null) return cleared(value.previous);
    return orElse();
  }

  R when<R>({
    required R Function() notInitialized,
    required R Function(CancelableOperation<T> operation, ComputedStateValue<T> previous) inProgress,
    required R Function(T value) ready,
    required R Function(Object exception) failed,
    required R Function(ComputedStateValue<T> previous) cleared,
  }) {
    return maybeWhen(
      notInitialized: notInitialized,
      inProgress: inProgress,
      ready: ready,
      failed: failed,
      cleared: cleared,
      orElse: () {
        throw StateError('Invalid ComputedStateValue descendant');
      },
    );
  }

  T? get valueOrNull => maybeWhen(ready: (value) => value, orElse: () => null);

  ComputedStateValue<T>? get previousOrNull =>
      maybeWhen(inProgress: (_, previous) => previous, cleared: (previous) => previous, orElse: () => null);

  T? get previousValueOrNull => previousOrNull?.valueOrPreviousOrNull;

  T? get valueOrPreviousOrNull => valueOrNull ?? previousValueOrNull;

  /// Note: [block] should be a pure function, since it may be called multiple times.
  ComputedStateValue<R> mapValue<R>(R Function(T) block) {
    return when(
      notInitialized: () => ComputedStateValue.notInitialized,
      inProgress: (operation, previous) => ComputedStateValue.inProgress(
        operation.then(block),
        previous: previous.mapValue(block),
      ),
      ready: (value) => ComputedStateValue.ready(block(value)),
      failed: ComputedStateValue.failed,
      cleared: (previous) => ComputedStateValue.cleared(previous: previous.mapValue(block)),
    );
  }
}

class ComputedStateValueNotInitialized extends ComputedStateValue<Never> with EquatableMixin {
  const ComputedStateValueNotInitialized._() : super._();

  @override
  List<Object?> get props => [];
}

class ComputedStateValueInProgress<T> extends ComputedStateValue<T> with EquatableMixin {
  final CancelableOperation<T> operation;
  final ComputedStateValue<T> previous;

  const ComputedStateValueInProgress._(this.operation, {required this.previous}) : super._();

  @override
  List<Object?> get props => [operation];
}

class ComputedStateValueReady<T> extends ComputedStateValue<T> with EquatableMixin {
  final T value;

  const ComputedStateValueReady._(this.value) : super._();

  @override
  List<Object?> get props => [value];
}

class ComputedStateValueFailed extends ComputedStateValue<Never> with EquatableMixin {
  final Object exception;

  const ComputedStateValueFailed._(this.exception) : super._();

  @override
  List<Object?> get props => [exception];
}

class ComputedStateValueCleared<T> extends ComputedStateValue<T> with EquatableMixin {
  final ComputedStateValue<T> previous;

  const ComputedStateValueCleared._({required this.previous}) : super._();

  @override
  List<Object?> get props => [previous];
}
