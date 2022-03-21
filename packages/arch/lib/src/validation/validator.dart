import 'dart:async';

import 'package:flutter/cupertino.dart';

mixin Validatable<T> {
  T get value;
  set errorMessage(ValidatorResult? result);

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

typedef ValidatorResult = String Function(BuildContext);

typedef Validator<T> = ValidatorResult? Function(T value);

typedef AsyncValidator<T> = FutureOr<ValidatorResult?> Function(T value);
