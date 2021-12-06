import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class Validatable<T> {
  T get value;
  set errorMessage(ValidatorResult? result);
}

typedef ValidatorResult = String Function(BuildContext);

typedef Validator<T> = ValidatorResult? Function(T value);

typedef AsyncValidator<T> = FutureOr<ValidatorResult?> Function(T value);
