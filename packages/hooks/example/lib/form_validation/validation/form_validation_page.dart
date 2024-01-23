import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/form_validation/validation/state/form_validation_page_state.dart';
import 'package:utopia_hooks_example/form_validation/validation/view/form_validation_page_view.dart';

class FormValidationPage extends StatelessWidget {
  const FormValidationPage();

  @override
  Widget build(BuildContext context) {
    return const HookCoordinator(
      use: useFormValidationPageState,
      builder: FormValidationPageView.new,
    );
  }
}
