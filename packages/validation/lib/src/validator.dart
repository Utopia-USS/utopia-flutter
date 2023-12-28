import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:utopia_utils/utopia_utils.dart';

typedef ValidatorResult = String Function(BuildContext);

typedef Validator<T> = ValidatorResult? Function(T value);

typedef AsyncValidator<T> = FutureOr<ValidatorResult?> Function(T value);

abstract interface class HasErrorMessage {
  abstract final ValidatorResult? errorMessage;
}

abstract interface class Validatable<T> implements Value<T>, HasErrorMessage {
  @override
  abstract ValidatorResult? errorMessage;
}

extension ValidatableExtensions<T> on Validatable<T> {
  bool get hasError => errorMessage != null;

  bool validate(Validator<T> validator) {
    final result = validator(value);
    errorMessage = result;
    return result == null;
  }

  Future<bool> validateAsync(AsyncValidator<T> validator) async {
    final result = await validator(value);
    errorMessage = result;
    return result == null;
  }
}
