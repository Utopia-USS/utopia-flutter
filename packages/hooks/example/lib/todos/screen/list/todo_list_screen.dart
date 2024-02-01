import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/todos/screen/edit/todo_edit_screen.dart';
import 'package:utopia_hooks_example/todos/screen/list/state/todo_list_screen_state.dart';
import 'package:utopia_hooks_example/todos/screen/list/view/todo_list_screen_view.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen();

  @override
  Widget build(BuildContext context) {
    return HookCoordinator(
      use: () => useTodoListScreenState(
        moveToEdit: (args) => unawaited(Navigator.of(context).push(TodoEditScreen.route(args))),
      ),
      builder: TodoListScreenView.new,
    );
  }
}
