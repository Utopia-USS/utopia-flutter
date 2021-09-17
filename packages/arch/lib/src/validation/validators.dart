import 'package:utopia_arch/src/input/field_state.dart';
import 'package:utopia_arch/src/validation/validator.dart';

class Validators {
  const Validators._();

  static Validator<T> combine<T>(List<Validator<T>> validators) {
    return (value) {
      for(final validator in validators) {
        final result = validator(value);
        if(result != null) return result;
      }
      return null;
    };
  }

  static AsyncValidator<T> combineAsync<T>(List<AsyncValidator<T>> validators) {
    return (value) async {
      for(final validator in validators) {
        final result = await validator(value);
        if(result != null) return result;
      }
      return null;
    };
  }

  static Validator<String> notEmpty({required ValidatorResult onEmpty}) {
    return (value) {
      if(value.isEmpty) return onEmpty;
      return null;
    };
  }

  static Validator<String> equals(FieldState other, {required ValidatorResult onNotEqual}) {
    return (value) {
      if(value != other.value) return onNotEqual;
      return null;
    };
  }
}