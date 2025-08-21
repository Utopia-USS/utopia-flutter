import 'package:flutter/material.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/state/use_todos_overview_page_state.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';

@visibleForTesting
enum TodosOverviewOption { toggleAll, clearCompleted }

class TodosOverviewOptionsButton extends StatelessWidget {
  final TodosOverviewPageState state;

  const TodosOverviewOptionsButton(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final todos = state.todos ?? [];
    final hasTodos = todos.isNotEmpty;
    final completedTodosAmount = todos.where((todo) => todo.isCompleted).length;

    return PopupMenuButton<TodosOverviewOption>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      tooltip: l10n.todosOverviewOptionsTooltip,
      onSelected: (options) {
        switch (options) {
          case TodosOverviewOption.toggleAll:
            state.onToggleAll();
          case TodosOverviewOption.clearCompleted:
            state.onClearCompleted();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosOverviewOption.toggleAll,
            enabled: hasTodos,
            child: Text(
              completedTodosAmount == todos.length
                  ? l10n.todosOverviewOptionsMarkAllIncomplete
                  : l10n.todosOverviewOptionsMarkAllComplete,
            ),
          ),
          PopupMenuItem(
            value: TodosOverviewOption.clearCompleted,
            enabled: hasTodos && completedTodosAmount > 0,
            child: Text(l10n.todosOverviewOptionsClearCompleted),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}
