import 'package:flutter/material.dart';
import 'package:utopia_widgets/layout/form_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('UtopiaWidgets example'),
        ),
        body: FormLayout.simple(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < 30; i++) Container(color: Colors.red, margin: const EdgeInsets.all(8), height: 50)
            ],
          ),
          bottom: Container(color: Colors.green, margin: const EdgeInsets.all(8), height: 50),
        ),
      ),
    );
  }
}
