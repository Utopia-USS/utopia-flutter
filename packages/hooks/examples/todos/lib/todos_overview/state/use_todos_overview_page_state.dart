import 'package:flutter_todos/todos_overview/models/todos_view_filter.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class TodosOverviewPageState {
  final List<Todo>? todos;
  final MutableValue<TodosViewFilter> filter;

  final void Function(Todo) onTodoCompletionToggled;
  final void Function(Todo) onTodoDeleted;
  final void Function() onToggleAll;
  final void Function() onClearCompleted;

  const TodosOverviewPageState({
    required this.todos,
    required this.filter,
    required this.onTodoCompletionToggled,
    required this.onTodoDeleted,
    required this.onToggleAll,
    required this.onClearCompleted,
  });

  bool get isLoading => todos == null;

  bool get isEmpty => todos!.isEmpty;
}

TodosOverviewPageState useTodosOverviewPageState({
  required void Function(Todo todo, {required void Function() onUndoPressed}) showUndoDeletionSnackbar,
  required void Function() showErrorSnackbar,
}) {
  final repository = useProvided<TodosRepository>();

  final todos = useMemoizedStreamData(repository.getTodos, onError: (_, __) => showErrorSnackbar());
  final filterState = useState(TodosViewFilter.all);

  Future<void> onToggleAll() async {
    final areAllCompleted = todos!.every((todo) => todo.isCompleted);
    await repository.completeAll(isCompleted: !areAllCompleted);
  }

  Future<void> onTodoDeleted(Todo todo) async {
    await repository.deleteTodo(todo.id);
    showUndoDeletionSnackbar(
      todo,
      onUndoPressed: () async => repository.saveTodo(todo),
    );
  }

  Future<void> onTodoCompletionToggled(Todo todo) async =>
      repository.saveTodo(todo.copyWith(isCompleted: !todo.isCompleted));

  final filteredTodos = useMemoized(() => todos?.where(filterState.value.apply).toList(), [todos, filterState.value]);

  return TodosOverviewPageState(
    todos: filteredTodos,
    filter: filterState,
    onToggleAll: onToggleAll,
    onTodoDeleted: onTodoDeleted,
    onTodoCompletionToggled: onTodoCompletionToggled,
    onClearCompleted: repository.clearCompleted,
  );
}
