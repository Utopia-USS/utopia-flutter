import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class _MockTodosRepository extends Mock implements TodosRepository {}

class _MockNavigation extends Mock {
  void moveBack();
}

class _FakeTodo extends Fake implements Todo {}

void main() {
  group('EditTodoState', () {
    late TodosRepository todosRepository;
    late _MockNavigation navigation;
    late SimpleHookContext<EditTodoPageState> context;

    SimpleHookContext<EditTodoPageState> buildContext({Todo? initialTodo}) {
      return SimpleHookContext(
        () => useEditTodoPageState(initialTodo: initialTodo, moveBack: navigation.moveBack),
        provided: {TodosRepository: todosRepository},
      );
    }

    setUpAll(() {
      registerFallbackValue(_FakeTodo());
    });

    setUp(() {
      navigation = _MockNavigation();
      todosRepository = _MockTodosRepository();
      when(() => todosRepository.saveTodo(any())).thenAnswer((_) => Future.value());
      context = buildContext();
    });

    test('has correct initial state', () {
      expect(context().isNewTodo, true);
      expect(context().isSubmitInProgress, false);
      expect(context().titleState.value, "");
      expect(context().descriptionState.value, "");
    });

    group("Submitting", () {
      test("sets isSubmitInProgress", () async {
        context().onSubmitPressed();

        expect(context().isSubmitInProgress, true);
      });

      test("moves back", () async {
        context().onSubmitPressed();
        await context.waitUntil((it) => !it.isSubmitInProgress);

        verify(() => navigation.moveBack()).called(1);
      });

      test("saves a new todo to repository if no initial todo was provided", () async {
        context().titleState.value = "title";
        context().onSubmitPressed();
        await context.waitUntil((it) => !it.isSubmitInProgress);

        final matcher = isA<Todo>().having((t) => t.title, "title", equals("title"));
        verify(() => todosRepository.saveTodo(any(that: matcher))).called(1);
      });

      test("saves an updated todo to repository if an initial todo was provided", () async {
        context = buildContext(initialTodo: Todo(id: "initial-id", title: "initial-title"));

        context().titleState.value = "title";
        context().onSubmitPressed();
        await context.waitUntil((it) => !it.isSubmitInProgress);

        final matchesTodo = isA<Todo>()
            .having((t) => t.id, "id", equals("initial-id"))
            .having((t) => t.title, "title", equals("title"));
        verify(() => todosRepository.saveTodo(any(that: matchesTodo))).called(1);
      });
    });
  });
}
