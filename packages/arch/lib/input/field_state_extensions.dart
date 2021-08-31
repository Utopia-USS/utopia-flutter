import 'package:utopia_arch/input/field_state.dart';
import 'package:utopia_arch/validation/validator.dart';

extension FieldStateExtensions on FieldState {
  bool validate(Validator<String> validator) {
    final result = validator(value);
    errorMessage = result;
    return result == null;
  }

  Future<bool> validateAsync(Validator<String> validator) async {
    final result = await validator(value);
    errorMessage = result;
    return result == null;
  }
}