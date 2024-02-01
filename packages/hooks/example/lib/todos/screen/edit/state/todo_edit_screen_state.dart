import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/todos/model/todo.dart';
import 'package:utopia_hooks_example/todos/screen/edit/todo_edit_screen.dart';
import 'package:utopia_hooks_example/todos/service/todo_service.dart';
import 'package:utopia_validation/utopia_validation.dart';

class TodoEditScreenState {
  final FieldState titleField;
  final bool isNew, isSaveInProgress;
  final void Function() onSavePressed;

  const TodoEditScreenState({
    required this.titleField,
    required this.isNew,
    required this.isSaveInProgress,
    required this.onSavePressed,
  });
}

TodoEditScreenState useTodoEditScreenState({required TodoEditScreenArgs args, required void Function() moveBack}) {
  final todoService = useProvided<TodoService>();

  final titleField = useFieldState(initialValue: args.todo?.title);

  final submitState = useSubmitState();

  bool validate() => titleField.validate(Validators.notEmpty(onEmpty: (_) => "Title must not be empty"));

  Future<void> submit() async => todoService.set(Todo(id: args.todo?.id ?? Todo.randomId(), title: titleField.value));

  void onSavePressed() {
    unawaited(submitState.runSimple<void, Never>(
      shouldSubmit: validate,
      submit: submit,
      afterSubmit: (_) => moveBack(),
    ));
  }

  return TodoEditScreenState(
    titleField: titleField,
    isNew: args.todo == null,
    isSaveInProgress: submitState.inProgress,
    onSavePressed: onSavePressed,
  );
}
