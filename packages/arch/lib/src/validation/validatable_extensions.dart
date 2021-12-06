import 'package:utopia_arch/src/validation/validator.dart';

extension ValidatableExtensions<T> on Validatable<T> {
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
