import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/todos/model/todo.dart';
import 'package:utopia_hooks_example/todos/screen/edit/state/todo_edit_screen_state.dart';
import 'package:utopia_hooks_example/todos/screen/edit/view/todo_edit_screen_view.dart';

class TodoEditScreenArgs {
  final Todo? todo;

  const TodoEditScreenArgs({required this.todo});
}

class TodoEditScreen extends StatelessWidget {
  static MaterialPageRoute<void> route(TodoEditScreenArgs args) =>
      MaterialPageRoute(settings: RouteSettings(arguments: args), builder: (_) => TodoEditScreen());

  @override
  Widget build(BuildContext context) {
    return HookCoordinator(
      use: () => useTodoEditScreenState(
        args: ModalRoute.of(context)!.settings.arguments! as TodoEditScreenArgs,
        moveBack: () => Navigator.of(context).pop(),
      ),
      builder: TodoEditScreenView.new,
    );
  }
}
