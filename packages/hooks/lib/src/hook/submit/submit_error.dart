// for convenience
export 'submit_state_extensions.dart';

abstract class SubmitError<E> {
  const SubmitError._();

  const factory SubmitError.unknown(Object exception, [StackTrace? stackTrace]) = SubmitErrorUnknown;

  const factory SubmitError.known(E error) = SubmitErrorKnown;

  T when<T>({required T Function(Object exception) unknown, required T Function(E error) known}) {
    final value = this;
    if (value is SubmitErrorUnknown) return unknown(value.exception);
    if (value is SubmitErrorKnown<E>) return known(value.error);
    throw StateError('Invalid SubmitError');
  }
}

class SubmitErrorUnknown extends SubmitError<Never> {
  final Object exception;
  final StackTrace? stackTrace;

  const SubmitErrorUnknown(this.exception, [this.stackTrace]) : super._();
}

class SubmitErrorKnown<E> extends SubmitError<E> {
  final E error;

  const SubmitErrorKnown(this.error) : super._();
}
