import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/edit_todo/state/use_edit_todo_page_state.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class EditTodoPage extends StatelessWidget {
  final Todo? initialTodo;

  const EditTodoPage(this.initialTodo, {super.key});

  @override
  Widget build(BuildContext context) {
    return HookCoordinator(
      use: () => useEditTodoPageState(
        initialTodo: initialTodo,
        moveBack: () => Navigator.of(context).pop(),
      ),
      builder: EditTodoView.new,
    );
  }

  static Route<void> route({Todo? initialTodo}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => EditTodoPage(initialTodo),
    );
  }
}

class EditTodoView extends StatelessWidget {
  final EditTodoPageState state;

  const EditTodoView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isNewTodo ? l10n.editTodoAddAppBarTitle : l10n.editTodoEditAppBarTitle),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.editTodoSaveButtonTooltip,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: state.isSubmitInProgress ? null : state.onSubmitPressed,
        child: state.isSubmitInProgress ? const CupertinoActivityIndicator() : const Icon(Icons.check_rounded),
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TitleField(state: state.titleState, submitInProgress: state.isSubmitInProgress),
                _DescriptionField(state: state.descriptionState, submitInProgress: state.isSubmitInProgress),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleField extends StatelessWidget {
  final FieldState state;
  final bool submitInProgress;

  const _TitleField({required this.state, required this.submitInProgress});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextEditingControllerWrapper(
      text: state,
      builder: (controller) => TextFormField(
        key: const Key('editTodoView_title_textFormField'),
        controller: controller,
        decoration: InputDecoration(
          enabled: !submitInProgress,
          labelText: l10n.editTodoTitleLabel,
        ),
        maxLength: 50,
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
        ],
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final FieldState state;
  final bool submitInProgress;

  const _DescriptionField({required this.state, required this.submitInProgress});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextEditingControllerWrapper(
      text: state,
      builder: (controller) => TextFormField(
        key: const Key('editTodoView_description_textFormField'),
        controller: controller,
        decoration: InputDecoration(
          enabled: !submitInProgress,
          labelText: l10n.editTodoDescriptionLabel,
        ),
        maxLength: 300,
        maxLines: 7,
        inputFormatters: [
          LengthLimitingTextInputFormatter(300),
        ],
      ),
    );
  }
}
