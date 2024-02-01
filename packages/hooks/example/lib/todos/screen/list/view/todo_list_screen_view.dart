import 'package:flutter/material.dart';
import 'package:utopia_hooks_example/todos/model/todo.dart';
import 'package:utopia_hooks_example/todos/screen/list/state/todo_list_screen_state.dart';

class TodoListScreenView extends StatelessWidget {
  final TodoListScreenState state;

  const TodoListScreenView(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todos")),
      body: state.isLoading ? const Center(child: CircularProgressIndicator()) : _buildList(),
      floatingActionButton: FloatingActionButton(onPressed: state.onCreatePressed, child: const Icon(Icons.add)),
    );
  }

  Widget _buildList() {
    if (state.isEmpty) return const Center(child: Text("No todos yet"));
    return ListView.builder(
      itemCount: state.todos!.length,
      itemBuilder: (context, index) => _buildTodo(state.todos![index]),
    );
  }

  Widget _buildTodo(Todo todo) {
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.check),
        onPressed: () => state.onTodoCompletePressed(todo),
      ),
      title: Text(todo.title),
      onTap: () => state.onTodoPressed(todo),
    );
  }
}
