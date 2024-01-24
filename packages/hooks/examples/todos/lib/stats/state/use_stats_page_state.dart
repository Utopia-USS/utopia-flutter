import 'package:todos_repository/todos_repository.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class StatsPageState {
  final int completedTodos, activeTodos;

  const StatsPageState({required this.activeTodos, required this.completedTodos});
}

StatsPageState useStatsPageState() {
  final repository = useProvided<TodosRepository>();

  final todos = useMemoizedStreamData(repository.getTodos);

  final completedCount = useMemoized(() => todos?.where((it) => it.isCompleted).length, [todos]);

  return StatsPageState(
    completedTodos: completedCount ?? 0,
    activeTodos: todos?.length.let((it) => it - completedCount!) ?? 0,
  );
}
