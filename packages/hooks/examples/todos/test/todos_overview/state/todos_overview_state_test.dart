import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class _MockTodosRepository extends Mock implements TodosRepository {}

class _FakeTodo extends Fake implements Todo {}

class _MockNavigation extends Mock {
  void showErrorSnackbar();

  void showUndoDeletionSnackbar(Todo todo, {required void Function() onUndoPressed});
}

void main() {
  final mockTodos = [
    Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    ),
    Todo(
      id: '2',
      title: 'title 2',
      description: 'description 2',
    ),
    Todo(
      id: '3',
      title: 'title 3',
      description: 'description 3',
      isCompleted: true,
    ),
  ];

  group('TodosOverviewState', () {
    late TodosRepository todosRepository;
    late _MockNavigation navigation;
    late StreamController<List<Todo>> todosController;
    late SimpleHookContext<TodosOverviewPageState> context;

    setUpAll(() {
      registerFallbackValue(_FakeTodo());
    });

    setUp(() {
      todosRepository = _MockTodosRepository();
      todosController = StreamController(sync: true);
      when(() => todosRepository.getTodos()).thenAnswer((_) => todosController.stream);
      when(() => todosRepository.saveTodo(any())).thenAnswer((_) => Future.value());
      when(() => todosRepository.deleteTodo(any())).thenAnswer((_) => Future.value());
      navigation = _MockNavigation();

      context = SimpleHookContext(
        () => useTodosOverviewPageState(
          showErrorSnackbar: navigation.showErrorSnackbar,
          showUndoDeletionSnackbar: navigation.showUndoDeletionSnackbar,
        ),
        provided: {TodosRepository: todosRepository},
      );
    });

    test("has correct initial state", () {
      expect(context().todos, null);
      expect(context().filter.value, TodosViewFilter.all);
    });

    test("updates todos when repository emits new todos", () {
      todosController.add(mockTodos);

      expect(context().todos, mockTodos);

      todosController.add(mockTodos.reversed.toList());

      expect(context().todos, mockTodos.reversed.toList());
    });

    group("filtering", () {
      setUp(() => todosController.add(mockTodos));

      for (final filter in TodosViewFilter.values) {
        test("shows filtered todos when filter is set to $filter", () {
          context().filter.value = filter;

          expect(context().todos, mockTodos.where(filter.apply).toList());
        });
      }
    });

    group("onTodoCompletionToggled", () {
      setUp(() => todosController.add(mockTodos));

      test("completes a todo in repository", () {
        context().onTodoCompletionToggled(mockTodos.first);

        final matcher =
            isA<Todo>().having((t) => t.id, "id", mockTodos.first.id).having((t) => t.isCompleted, "isCompleted", true);

        verify(() => todosRepository.saveTodo(any(that: matcher))).called(1);
      });

      test("un-completes a todo in repository", () {
        context().onTodoCompletionToggled(mockTodos.last);

        final matcher =
            isA<Todo>().having((t) => t.id, "id", mockTodos.last.id).having((t) => t.isCompleted, "isCompleted", false);

        verify(() => todosRepository.saveTodo(any(that: matcher))).called(1);
      });
    });

    group("onToggleAll", () {
      test("completes all when some are completed", () {
        todosController.add(mockTodos);
        context().onToggleAll();

        verify(() => todosRepository.completeAll(isCompleted: true)).called(1);
      });

      test("completes all when none are completed", () {
        todosController.add(mockTodos.map((todo) => todo.copyWith(isCompleted: false)).toList());
        context().onToggleAll();

        verify(() => todosRepository.completeAll(isCompleted: true)).called(1);
      });

      test("un-completes all when all are completed", () {
        todosController.add(mockTodos.map((todo) => todo.copyWith(isCompleted: true)).toList());
        context().onToggleAll();

        verify(() => todosRepository.completeAll(isCompleted: false)).called(1);
      });
    });

    group("onTodoDeleted", () {
      final idMatcher = equals(mockTodos.first.id);
      final todoMatcher = isA<Todo>().having((t) => t.id, "id", idMatcher);

      setUp(() {
        todosController.add(mockTodos);
        context().onTodoDeleted(mockTodos.first);
      });

      test("deletes a todo from repository", () {
        verify(() => todosRepository.deleteTodo(any(that: idMatcher))).called(1);
      });

      test("shows undo deletion snackbar", () {
        verify(
          () => navigation.showUndoDeletionSnackbar(any(that: todoMatcher), onUndoPressed: any(named: "onUndoPressed")),
        ).called(1);
      });

      test("restores a todo when undo deletion snackbar is pressed", () {
        final onUndoPressed = verify(
          () => navigation.showUndoDeletionSnackbar(any(), onUndoPressed: captureAny(named: "onUndoPressed")),
        ).captured.single;
        onUndoPressed();

        verify(() => todosRepository.saveTodo(any(that: todoMatcher))).called(1);
      });
    });

    group("onClearCompleted", () {
      test("clears completed todos from repository", () {
        todosController.add(mockTodos);
        context().onClearCompleted();

        verify(() => todosRepository.clearCompleted()).called(1);
      });
    });
  });
}
