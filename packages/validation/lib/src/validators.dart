import 'package:utopia_validation/src/validator.dart';

class Validators {
  const Validators._();

  static Validator<T> combine<T>(List<Validator<T>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  static AsyncValidator<T> combineAsync<T>(List<AsyncValidator<T>> validators) {
    return (value) async {
      for (final validator in validators) {
        final result = await validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  static Validator<String> notEmpty({required ValidatorResult onEmpty}) {
    return (value) {
      if (value.isEmpty) return onEmpty;
      return null;
    };
  }

  static Validator<T> conditional<T>(bool Function(T) test, {required ValidatorResult onFalse}) {
    return (value) {
      if (test(value)) return onFalse;
      return null;
    };
  }

  static Validator<T> equals<T>(T other, {required ValidatorResult onNotEqual}) {
    return (value) {
      if (value != other) return onNotEqual;
      return null;
    };
  }
}
