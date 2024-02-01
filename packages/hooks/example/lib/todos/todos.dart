import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/firebase_options.dart';
import 'package:utopia_hooks_example/todos/screen/list/todo_list_screen.dart';
import 'package:utopia_hooks_example/todos/service/todo_service.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TodosApp());
}

class TodosApp extends StatelessWidget {
  static const todoService = TodoService();

  const TodosApp();

  @override
  Widget build(BuildContext context) {
    return ValueProvider(
      todoService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todos',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const TodoListScreen(),
      ),
    );
  }
}
