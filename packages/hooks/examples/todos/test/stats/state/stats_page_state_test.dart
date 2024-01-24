import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/stats/stats.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class _MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  final activeTodo = Todo(
    title: 'title 1',
    description: 'description 1',
  );
  final completedTodo = Todo(
    title: 'title 2',
    description: 'description 2',
    isCompleted: true,
  );

  group('StatsPageState', () {
    late TodosRepository todosRepository;
    late SimpleHookContext<StatsPageState> context;
    late StreamController<List<Todo>> todosController;

    setUp(() {
      todosRepository = _MockTodosRepository();
      todosController = StreamController(sync: true);
      when(() => todosRepository.getTodos()).thenAnswer((_) => todosController.stream);
      context = SimpleHookContext(useStatsPageState, provided: {TodosRepository: todosRepository});
    });

    test('has correct loading state', () {
      expect(context().completedTodos, 0);
      expect(context().activeTodos, 0);
    });

    test("has correct empty completed/active count", () {
      todosController.add([]);

      expect(context().completedTodos, 0);
      expect(context().activeTodos, 0);
    });

    test('has correct non-empty completed/active count', () {
      todosController.add([activeTodo, activeTodo, completedTodo]);

      expect(context().completedTodos, 1);
      expect(context().activeTodos, 2);
    });
  });
}
