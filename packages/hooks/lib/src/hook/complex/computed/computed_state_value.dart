import 'package:async/async.dart';
import 'package:equatable/equatable.dart';

abstract class ComputedStateValue<T> {
  const ComputedStateValue._();

  static const ComputedStateValue<Never> notInitialized = ComputedStateValueNotInitialized._();

  const factory ComputedStateValue.inProgress(CancelableOperation<T> operation) = ComputedStateValueInProgress._;

  const factory ComputedStateValue.ready(T value) = ComputedStateValueReady._;

  const factory ComputedStateValue.failed(Object exception) = ComputedStateValueFailed._;

  R maybeWhen<R>({
    R Function()? notInitialized,
    R Function(CancelableOperation<T> operation)? inProgress,
    R Function(T value)? ready,
    R Function(Object exception)? failed,
    required R Function() orElse,
  }) {
    final value = this;
    if (value is ComputedStateValueNotInitialized && notInitialized != null) return notInitialized();
    if (value is ComputedStateValueInProgress<T> && inProgress != null) {
      return inProgress(value.operation);
    }
    if (value is ComputedStateValueReady<T> && ready != null) return ready(value.value);
    if (value is ComputedStateValueFailed && failed != null) return failed(value.exception);
    return orElse();
  }

  R when<R>({
    required R Function() notInitialized,
    required R Function(CancelableOperation<T> operation) inProgress,
    required R Function(T value) ready,
    required R Function(Object exception) failed,
  }) {
    return maybeWhen(
      notInitialized: notInitialized,
      inProgress: inProgress,
      ready: ready,
      failed: failed,
      orElse: () {
        throw StateError('Invalid ComputedStateValue descendant');
      },
    );
  }

  T? get valueOrNull => maybeWhen(ready: (value) => value, orElse: () => null);

  /// Note: [block] should be a pure function, since it may be called multiple times.
  ComputedStateValue<R> mapValue<R>(R Function(T) block) {
    return when(
      notInitialized: () => ComputedStateValue.notInitialized,
      inProgress: (operation) => ComputedStateValue.inProgress(operation.then(block)),
      ready: (value) => ComputedStateValue.ready(block(value)),
      failed: ComputedStateValue.failed,
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

  const ComputedStateValueInProgress._(this.operation) : super._();

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
