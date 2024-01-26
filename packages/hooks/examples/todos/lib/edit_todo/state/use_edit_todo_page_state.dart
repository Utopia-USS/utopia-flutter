import 'package:todos_repository/todos_repository.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class EditTodoPageState {
  final FieldState titleState, descriptionState;
  final bool isNewTodo, isSubmitInProgress;
  final Future<void> Function() onSubmitPressed;

  const EditTodoPageState({
    required this.titleState,
    required this.descriptionState,
    required this.isNewTodo,
    required this.isSubmitInProgress,
    required this.onSubmitPressed,
  });
}

EditTodoPageState useEditTodoPageState({Todo? initialTodo, required void Function() moveBack}) {
  final repository = useProvided<TodosRepository>();

  final titleState = useFieldState(initialValue: initialTodo?.title);
  final descriptionState = useFieldState(initialValue: initialTodo?.description);
  final submitState = useSubmitState();

  Future<void> onSubmitPressed() async {
    submitState.run(() async {
      final todo = Todo(id: initialTodo?.id, title: titleState.value, description: descriptionState.value);
      await repository.saveTodo(todo);
      moveBack();
    });
  }

  return EditTodoPageState(
    titleState: titleState,
    descriptionState: descriptionState,
    isSubmitInProgress: submitState.inProgress,
    isNewTodo: initialTodo == null,
    onSubmitPressed: onSubmitPressed,
  );
}
