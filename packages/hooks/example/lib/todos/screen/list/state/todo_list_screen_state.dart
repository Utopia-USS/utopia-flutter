import 'dart:async';

import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/todos/model/todo.dart';
import 'package:utopia_hooks_example/todos/screen/edit/todo_edit_screen.dart';
import 'package:utopia_hooks_example/todos/service/todo_service.dart';

class TodoListScreenState {
  final List<Todo>? todos;
  final void Function(Todo todo) onTodoPressed, onTodoCompletePressed;
  final void Function() onCreatePressed;

  const TodoListScreenState({
    required this.todos,
    required this.onTodoPressed,
    required this.onTodoCompletePressed,
    required this.onCreatePressed,
  });

  bool get isLoading => todos == null;
  bool get isEmpty => todos!.isEmpty;
}

TodoListScreenState useTodoListScreenState({required void Function(TodoEditScreenArgs args) moveToEdit}) {
  final todoService = useProvided<TodoService>();

  final todos = useMemoizedStreamData(todoService.createActiveStream);

  void onTodoCompletePressed(Todo todo) => unawaited(todoService.markCompleted(todo.id));

  return TodoListScreenState(
    todos: todos,
    onTodoPressed: (todo) => moveToEdit(TodoEditScreenArgs(todo: todo)),
    onTodoCompletePressed: onTodoCompletePressed,
    onCreatePressed: () => moveToEdit(const TodoEditScreenArgs(todo: null)),
  );
}
