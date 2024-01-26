import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todos/edit_todo/view/edit_todo_page.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_api/todos_api.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class TodosOverviewPage extends StatelessWidget {
  const TodosOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HookCoordinator(
      use: () => useTodosOverviewPageState(
        showErrorSnackbar: () => _showErrorSnackbar(context),
        showUndoDeletionSnackbar: (todo, {required onUndoPressed}) =>
            _showUndoDeletionSnackbar(context, todo, onUndoPressed: onUndoPressed),
      ),
      builder: TodosOverviewView.new,
    );
  }

  static void _showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.todosOverviewErrorSnackbarText)));
  }

  static void _showUndoDeletionSnackbar(BuildContext context, Todo todo, {required void Function() onUndoPressed}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.todosOverviewTodoDeletedSnackbarText(
              todo.title,
            ),
          ),
          action: SnackBarAction(
            label: context.l10n.todosOverviewUndoDeletionButtonText,
            onPressed: () {
              messenger.hideCurrentSnackBar();
              onUndoPressed();
            },
          ),
        ),
      );
  }
}

class TodosOverviewView extends HookWidget {
  final TodosOverviewPageState state;

  const TodosOverviewView(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.todosOverviewAppBarTitle),
        actions: [
          TodosOverviewFilterButton(state),
          TodosOverviewOptionsButton(state),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading) return const Center(child: CupertinoActivityIndicator());
    if (state.todos!.isEmpty) {
      return Center(
        child: Text(
          context.l10n.todosOverviewEmptyText,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return CupertinoScrollbar(
      child: ListView(
        children: [
          for (final todo in state.todos!)
            TodoListTile(
              todo: todo,
              onToggleCompleted: (isCompleted) => state.onTodoCompletionToggled(todo),
              onDismissed: (_) => state.onTodoDeleted(todo),
              onTap: () => Navigator.of(context).push(EditTodoPage.route(initialTodo: todo)),
            ),
        ],
      ),
    );
  }
}
