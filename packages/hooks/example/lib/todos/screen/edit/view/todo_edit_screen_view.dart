import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/todos/screen/edit/state/todo_edit_screen_state.dart';

class TodoEditScreenView extends StatelessWidget {
  final TodoEditScreenState state;

  const TodoEditScreenView(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(state.isNew ? "New Todo" : "Edit Todo"),
      actions: [
        if (state.isSaveInProgress)
          const Center(child: CircularProgressIndicator())
        else
          IconButton(icon: const Icon(Icons.done), onPressed: state.onSavePressed),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextEditingControllerWrapper(
        text: state.titleField,
        builder: (controller) => TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Title",
            errorText: state.titleField.errorMessage?.let((it) => it(context)),
          ),
        ),
      ),
    );
  }
}
