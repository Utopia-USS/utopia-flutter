import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef ValidatorResult = String Function(BuildContext);

typedef Validator<T> = ValidatorResult? Function(T value);

typedef AsyncValidator<T> = FutureOr<ValidatorResult?> Function(T value);
