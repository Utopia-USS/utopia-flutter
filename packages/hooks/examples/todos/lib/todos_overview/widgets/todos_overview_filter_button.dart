import 'package:flutter/material.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class TodosOverviewFilterButton extends StatelessWidget {
  final TodosOverviewPageState state;

  const TodosOverviewFilterButton(this.state);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopupMenuButton<TodosViewFilter>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: state.filter.value,
      tooltip: l10n.todosOverviewFilterTooltip,
      onSelected: state.filter.set,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosViewFilter.all,
            child: Text(l10n.todosOverviewFilterAll),
          ),
          PopupMenuItem(
            value: TodosViewFilter.activeOnly,
            child: Text(l10n.todosOverviewFilterActiveOnly),
          ),
          PopupMenuItem(
            value: TodosViewFilter.completedOnly,
            child: Text(l10n.todosOverviewFilterCompletedOnly),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}
