import 'package:flutter/material.dart';
import 'package:utopia_hooks_example/form_validation/validation/form_validation_page.dart';

void main() => runApp(const FormApp());

class FormApp extends StatelessWidget {
  const FormApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FormValidationPage(),
    );
  }
}
