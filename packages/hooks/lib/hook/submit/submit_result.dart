import 'package:utopia_hooks/hook/submit/submit_error.dart';

abstract class SubmitResult<T, E> {
  const SubmitResult._();

  const factory SubmitResult.alreadySubmitting() = SubmitResultAlreadySubmitting;
  const factory SubmitResult.shouldNotSubmit() = SubmitResultShouldNotSubmit;
  const factory SubmitResult.error(SubmitError<E> error) = SubmitResultError;
  const factory SubmitResult.success(T value) = SubmitResultSuccess;
}

class SubmitResultAlreadySubmitting extends SubmitResult<Never, Never> {
  const SubmitResultAlreadySubmitting() : super._();
}

class SubmitResultShouldNotSubmit extends SubmitResult<Never, Never> {
  const SubmitResultShouldNotSubmit() : super._();
}

class SubmitResultError<E> extends SubmitResult<Never, E> {
  final SubmitError<E> error;

  const SubmitResultError(this.error) : super._();
}

class SubmitResultSuccess<T> extends SubmitResult<T, Never> {
  final T value;

  const SubmitResultSuccess(this.value) : super._();
}

