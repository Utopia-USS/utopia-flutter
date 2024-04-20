import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/form_validation/validation/state/form_validation_page_state.dart';

class FormValidationPageView extends StatelessWidget {
  final FormValidationPageState state;

  const FormValidationPageView(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Flutter demo form validation page"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextField(state.emailState, "E-mail"),
          _buildTextField(state.passwordState, "Password"),
          _buildTextField(state.repeatPasswordState, "Repeat password"),
          const Spacer(),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: state.onSubmitPressed,
      child: state.isInProgress ? const CircularProgressIndicator() : const Text("Validate"),
    );
  }

  Widget _buildTextField(FieldState state, String label) {
    return Builder(
      builder: (context) {
        final errorMessage = state.errorMessage;
        return TextEditingControllerWrapper(
          text: state,
          builder: (controller) => TextField(
            controller: controller,
            decoration: InputDecoration(
              label: Text(label),
              error: errorMessage != null ? Text(errorMessage(context)) : null,
            ),
          ),
        );
      },
    );
  }
}
