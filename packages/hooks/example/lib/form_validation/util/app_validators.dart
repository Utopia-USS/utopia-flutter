import 'package:utopia_hooks_example/form_validation/util/app_regex_patterns.dart';
import 'package:utopia_validation/utopia_validation.dart';

class AppValidators {
  AppValidators._();

  static Validator<String> passwordValidator = Validators.combine<String>([
    notEmpty,
    Validators.conditional<String>(
      (value) => value.length < 8 || !RegexPattern.passwordExp.hasMatch(value),
      onFalse: (context) =>
          "Password needs to be 8 characters long and consist of small letters, big letters, a number and a special character",
    ),
  ]);

  static Validator<String> repeatPasswordValidator(String password) {
    return Validators.combine([
      notEmpty,
      Validators.conditional(
        (value) => value != password,
        onFalse: (context) => "Passwords do not match",
      ),
    ]);
  }

  static Validator<String> emailValidator = Validators.combine([
    notEmpty,
    Validators.conditional(
      (value) => !RegexPattern.emailExp.hasMatch(value),
      onFalse: (context) => "Incorrect email structure",
    ),
  ]);

  static final notEmpty = Validators.notEmpty(onEmpty: (context) => "Field cannot be empty");
}
