import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/form_validation/util/app_validators.dart';
import 'package:utopia_validation/utopia_validation.dart';

class FormValidationPageState {
  final FieldState emailState, passwordState, repeatPasswordState;
  final bool isInProgress;
  final void Function() onSubmitPressed;

  const FormValidationPageState({
    required this.emailState,
    required this.passwordState,
    required this.repeatPasswordState,
    required this.isInProgress,
    required this.onSubmitPressed,
  });
}

FormValidationPageState useFormValidationPageState() {
  final emailState = useFieldState();
  final passwordState = useFieldState();
  final repeatPasswordState = useFieldState();

  final submitState = useSubmitState();

  bool validate() {
    return [
      emailState.validate(AppValidators.emailValidator),
      passwordState.validate(AppValidators.passwordValidator),
      repeatPasswordState.validate(AppValidators.repeatPasswordValidator(passwordState.value)),
    ].every((e) => e);
  }

  Future<void> mockQuery() async => Future.delayed(const Duration(seconds: 1));

  Future<void> submit() async {
    await submitState.runSimple<void, Never>(
      shouldSubmit: () => !submitState.inProgress && validate(),
      submit: mockQuery,
    );
  }

  return FormValidationPageState(
    emailState: emailState,
    passwordState: passwordState,
    repeatPasswordState: repeatPasswordState,
    isInProgress: submitState.inProgress,
    onSubmitPressed: submit,
  );
}
